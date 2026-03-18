import 'package:flutter/material.dart';

class TbProgressIndicator extends ProgressIndicator {

  const TbProgressIndicator({
    super.key,
    this.size = 36.0,
    super.valueColor,
    super.semanticsLabel,
    super.semanticsValue,
  }) : super(
          value: null,
        );
  final double size;

  @override
  State<StatefulWidget> createState() => _TbProgressIndicatorState();

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).primaryColor;
}

class _TbProgressIndicatorState extends State<TbProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          widget._getValueColor(context),
        ),
        strokeWidth: 3.0,
      ),
    );
  }
}
