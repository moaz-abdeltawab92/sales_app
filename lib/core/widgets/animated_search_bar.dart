import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final List<String>? searchPhrases;
  final String prefixText;
  final Color? accentColor;
  final String? hintText;
  final EdgeInsetsGeometry? padding;

  const AnimatedSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.searchPhrases,
    this.prefixText = 'Search ',
    this.accentColor,
    this.hintText,
    this.padding,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  late final TextEditingController _internalController;
  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _effectiveController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() {});
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    } else {
      widget.controller?.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  void _clearSearch() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final activeAccent = widget.accentColor ?? AppColors.primaryLight;
    final defaultPhrases = ['customer by name...'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          TextField(
            controller: _effectiveController,
            onChanged: widget.onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textMuted,
                size: 20,
              ),
              suffixIcon: _effectiveController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (_effectiveController.text.isEmpty)
            Positioned(
              left: 48,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: _AnimatedSearchPlaceholder(
                    phrases: widget.searchPhrases ?? defaultPhrases,
                    prefixText: widget.prefixText,
                    accentColor: activeAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedSearchPlaceholder extends StatefulWidget {
  final List<String> phrases;
  final String prefixText;
  final Color accentColor;

  const _AnimatedSearchPlaceholder({
    required this.phrases,
    required this.prefixText,
    required this.accentColor,
  });

  @override
  State<_AnimatedSearchPlaceholder> createState() =>
      __AnimatedSearchPlaceholderState();
}

class __AnimatedSearchPlaceholderState
    extends State<_AnimatedSearchPlaceholder> {
  int _currentWordIndex = 0;
  String _currentText = '';
  bool _isDeleting = false;
  late final ValueNotifier<String> _textNotifier;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _textNotifier = ValueNotifier<String>('');
    _startAnimation();
  }

  void _startAnimation() {
    const typingSpeed = Duration(milliseconds: 100);
    const deletingSpeed = Duration(milliseconds: 50);
    const pauseDuration = Duration(milliseconds: 1600);

    void tick() {
      if (!mounted) return;
      if (widget.phrases.isEmpty) return;

      final fullWord = widget.phrases[_currentWordIndex];

      if (!_isDeleting) {
        if (_currentText.length < fullWord.length) {
          _currentText = fullWord.substring(0, _currentText.length + 1);
          _textNotifier.value = _currentText;
          _timer = Timer(typingSpeed, tick);
        } else {
          _isDeleting = true;
          _timer = Timer(pauseDuration, tick);
        }
      } else {
        if (_currentText.isNotEmpty) {
          _currentText = _currentText.substring(0, _currentText.length - 1);
          _textNotifier.value = _currentText;
          _timer = Timer(deletingSpeed, tick);
        } else {
          _isDeleting = false;
          _currentWordIndex = (_currentWordIndex + 1) % widget.phrases.length;
          _timer = Timer(typingSpeed, tick);
        }
      }
    }

    _timer = Timer(typingSpeed, tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _textNotifier,
      builder: (context, animatedVal, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.prefixText.isNotEmpty)
              Text(
                widget.prefixText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.normal,
                ),
              ),
            Text(
              animatedVal,
              style: TextStyle(
                fontSize: 14,
                color: widget.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            _BlinkingCursor(accentColor: widget.accentColor),
          ],
        );
      },
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color accentColor;

  const _BlinkingCursor({required this.accentColor});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        '|',
        style: TextStyle(
          fontSize: 14,
          color: widget.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
