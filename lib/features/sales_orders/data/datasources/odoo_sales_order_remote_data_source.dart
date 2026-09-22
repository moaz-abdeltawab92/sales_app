import '../../../../core/errors/failures.dart';
import '../../../../core/network/odoo_rpc_client.dart';
import '../models/sale_order_line_model.dart';
import '../models/sale_order_model.dart';
import 'sales_order_remote_data_source.dart';

/// Real Odoo JSON-RPC implementation of [SalesOrderRemoteDataSource] using `sale.order` & `sale.order.line`.
class OdooSalesOrderRemoteDataSource implements SalesOrderRemoteDataSource {
  final OdooRpcClient client;

  OdooSalesOrderRemoteDataSource({required this.client});

  @override
  Future<List<SaleOrderModel>> getSalesOrders() async {
    try {
      // Step 1: Fetch all sales orders
      final orderResponse = await client.executeKw(
        model: 'sale.order',
        method: 'search_read',
        args: [[]], // Fetch all orders
        kwargs: {
          'fields': [
            'id',
            'name',
            'partner_id',
            'date_order',
            'state',
            'amount_total',
            'order_line',
          ],
          'order': 'date_order desc',
          'limit': 100,
        },
      );

      if (orderResponse is! List) {
        throw const ServerFailure('Invalid sales order response from Odoo');
      }

      final List<Map<String, dynamic>> orderMaps = orderResponse
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      // Collect all order_line IDs across all orders
      final List<int> allLineIds = [];
      for (final oMap in orderMaps) {
        final rawLines = oMap['order_line'];
        if (rawLines is List) {
          for (final lineId in rawLines) {
            if (lineId is int) allLineIds.add(lineId);
          }
        }
      }

      // Step 2: Fetch line item details if any lines exist
      final Map<int, List<SaleOrderLineModel>> linesByOrderId = {};

      if (allLineIds.isNotEmpty) {
        final lineResponse = await client.executeKw(
          model: 'sale.order.line',
          method: 'search_read',
          args: [
            [
              ['id', 'in', allLineIds]
            ]
          ],
          kwargs: {
            'fields': [
              'id',
              'order_id',
              'product_id',
              'name',
              'product_uom_qty',
              'price_unit',
              'price_subtotal',
            ],
          },
        );

        if (lineResponse is List) {
          for (final lItem in lineResponse) {
            final lMap = Map<String, dynamic>.from(lItem as Map);
            final orderId = _extractMany2OneId(lMap['order_id']);
            if (orderId != null) {
              final lineModel = _mapToOrderLineModel(lMap);
              linesByOrderId.putIfAbsent(orderId, () => []).add(lineModel);
            }
          }
        }
      }

      // Step 3: Construct SaleOrderModel list
      final List<SaleOrderModel> orders = orderMaps.map((oMap) {
        final orderId = OdooRpcClient.parseInt(oMap['id']);
        final orderLines = linesByOrderId[orderId] ?? <SaleOrderLineModel>[];
        return _mapToSaleOrderModel(oMap, orderLines);
      }).toList();

      return orders;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Failed to fetch sales orders from Odoo: ${e.toString()}');
    }
  }

  @override
  Future<SaleOrderModel> confirmSalesOrder(int orderId) async {
    try {
      // Step 1: Execute action_confirm on sale.order
      final result = await client.executeKw(
        model: 'sale.order',
        method: 'action_confirm',
        args: [
          [orderId]
        ],
      );

      // action_confirm typically returns true or a dictionary action
      if (result != true && result is! Map) {
        throw const ServerFailure('Failed to confirm sales order on Odoo');
      }

      // Step 2: Re-read the confirmed sales order from Odoo
      final updatedOrders = await client.executeKw(
        model: 'sale.order',
        method: 'search_read',
        args: [
          [
            ['id', '=', orderId]
          ]
        ],
        kwargs: {
          'fields': [
            'id',
            'name',
            'partner_id',
            'date_order',
            'state',
            'amount_total',
            'order_line',
          ],
          'limit': 1,
        },
      );

      if (updatedOrders is List && updatedOrders.isNotEmpty) {
        final oMap = Map<String, dynamic>.from(updatedOrders.first as Map);

        // Fetch lines for this single order
        final rawLines = oMap['order_line'];
        final List<SaleOrderLineModel> orderLines = [];

        if (rawLines is List && rawLines.isNotEmpty) {
          final lineIds = rawLines.whereType<int>().toList();
          if (lineIds.isNotEmpty) {
            final lineResponse = await client.executeKw(
              model: 'sale.order.line',
              method: 'search_read',
              args: [
                [
                  ['id', 'in', lineIds]
                ]
              ],
              kwargs: {
                'fields': [
                  'id',
                  'order_id',
                  'product_id',
                  'name',
                  'product_uom_qty',
                  'price_unit',
                  'price_subtotal',
                ],
              },
            );

            if (lineResponse is List) {
              for (final lItem in lineResponse) {
                final lMap = Map<String, dynamic>.from(lItem as Map);
                orderLines.add(_mapToOrderLineModel(lMap));
              }
            }
          }
        }

        return _mapToSaleOrderModel(oMap, orderLines);
      }

      throw const ServerFailure('Confirmed order not found after update');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Failed to confirm sales order: ${e.toString()}');
    }
  }

  int? _extractMany2OneId(dynamic fieldVal) {
    if (fieldVal is List && fieldVal.isNotEmpty && fieldVal.first is int) {
      return fieldVal.first as int;
    }
    return null;
  }

  String _extractMany2OneName(dynamic fieldVal, [String fallback = '']) {
    if (fieldVal is List && fieldVal.length > 1 && fieldVal[1] is String) {
      return fieldVal[1] as String;
    }
    return fallback;
  }

  SaleOrderModel _mapToSaleOrderModel(
    Map<String, dynamic> json,
    List<SaleOrderLineModel> lines,
  ) {
    final id = OdooRpcClient.parseInt(json['id']);
    final orderNumber = OdooRpcClient.parseString(json['name'], 'SO#$id');
    final customerName = _extractMany2OneName(json['partner_id'], 'Customer');

    final rawState = OdooRpcClient.parseString(json['state'], 'draft').toLowerCase();
    // Map Odoo states: draft/sent -> draft; sale/done -> sale
    final status = (rawState == 'sale' || rawState == 'done') ? 'sale' : 'draft';

    final rawDate = json['date_order'];
    DateTime dateOrder = DateTime.now();
    if (rawDate is String && rawDate.isNotEmpty) {
      final formattedStr = rawDate.contains(' ') ? rawDate.replaceAll(' ', 'T') : rawDate;
      dateOrder = DateTime.tryParse(formattedStr) ?? DateTime.now();
    }

    final totalAmount = OdooRpcClient.parseDouble(json['amount_total']);

    return SaleOrderModel(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      orderDate: dateOrder,
      status: status,
      lines: lines,
      totalAmount: totalAmount,
    );
  }

  SaleOrderLineModel _mapToOrderLineModel(Map<String, dynamic> json) {
    final id = OdooRpcClient.parseInt(json['id']);

    final descName = OdooRpcClient.parseString(json['name']);
    final productNameFromRel = _extractMany2OneName(json['product_id']);
    final productName = productNameFromRel.isNotEmpty
        ? productNameFromRel
        : (descName.isNotEmpty ? descName : 'Product #$id');

    final quantity = OdooRpcClient.parseDouble(json['product_uom_qty'], 1.0);
    final unitPrice = OdooRpcClient.parseDouble(json['price_unit'], 0.0);

    return SaleOrderLineModel(
      id: id,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}
