import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:greens_app/utils/app_colors.dart';

/// Classe utilitaire pour faciliter la création de graphiques avec syncfusion_flutter_charts
class ChartUtils {
  /// Crée une série de données pour un graphique en ligne
  static LineSeries<T, num> createLineSeries<T>({
    required List<T> data,
    required String name,
    required Color color,
    required num Function(T, int) xValueMapper,
    required num Function(T, int) yValueMapper,
    double width = 2,
    bool enableTooltip = true,
    MarkerSettings? markerSettings,
    bool enableGradient = false,
  }) {
    return LineSeries<T, num>(
      dataSource: data,
      name: name,
      color: color,
      width: width,
      xValueMapper: xValueMapper,
      yValueMapper: yValueMapper,
      enableTooltip: enableTooltip,
      markerSettings: markerSettings ?? const MarkerSettings(isVisible: true),
      // Le gradient n'est pas supporté directement, nous utilisons une autre approche
      onCreateRenderer: enableGradient ? (ChartSeries<T, num> series) {
        return _LineSeriesRenderer<T>(
          series as LineSeries<T, num>, 
          color.withOpacity(0.5), 
          color
        );
      } : null,
    );
  }

  /// Crée une série de données pour un graphique en barres
  static ColumnSeries<T, dynamic> createBarSeries<T>({
    required List<T> data,
    required String name,
    required Color color,
    required dynamic Function(T, int) xValueMapper,
    required num Function(T, int) yValueMapper,
    double width = 0.8,
    bool enableTooltip = true,
    BorderRadius? borderRadius,
  }) {
    return ColumnSeries<T, dynamic>(
      dataSource: data,
      name: name,
      color: color,
      width: width,
      xValueMapper: xValueMapper,
      yValueMapper: yValueMapper,
      enableTooltip: enableTooltip,
      borderRadius: borderRadius ?? BorderRadius.zero,
    );
  }

  /// Crée une série de données pour un graphique circulaire
  static PieSeries<T, dynamic> createPieSeries<T>({
    required List<T> data,
    required dynamic Function(T, int) xValueMapper,
    required num Function(T, int) yValueMapper,
    String? dataLabelMapper,
    bool enableTooltip = true,
    bool showLabels = true,
  }) {
    return PieSeries<T, dynamic>(
      dataSource: data,
      xValueMapper: xValueMapper,
      yValueMapper: yValueMapper,
      dataLabelMapper: dataLabelMapper != null 
          ? (T data, int index) => dataLabelMapper 
          : null,
      enableTooltip: enableTooltip,
      dataLabelSettings: DataLabelSettings(
        isVisible: showLabels,
        labelPosition: ChartDataLabelPosition.outside,
      ),
    );
  }

  /// Crée un graphique en ligne
  static SfCartesianChart createLineChart({
    required List<ChartSeries> series,
    String? title,
    String? xAxisTitle,
    String? yAxisTitle,
    bool showLegend = true,
    bool enableZooming = false,
    bool enablePanning = false,
    bool enableTooltip = true,
    bool enableCrosshair = false,
    bool enableTrackball = false,
    EdgeInsets margin = const EdgeInsets.all(10),
    NumericAxis? primaryXAxis,
    NumericAxis? primaryYAxis,
  }) {
    return SfCartesianChart(
      title: title != null 
          ? ChartTitle(text: title)
          : null,
      legend: Legend(
        isVisible: showLegend,
        position: LegendPosition.bottom,
      ),
      margin: margin,
      zoomPanBehavior: enableZooming || enablePanning
          ? ZoomPanBehavior(
              enablePinching: enableZooming,
              enablePanning: enablePanning,
              zoomMode: ZoomMode.x,
            )
          : null,
      tooltipBehavior: enableTooltip
          ? TooltipBehavior(enable: true)
          : null,
      crosshairBehavior: enableCrosshair
          ? CrosshairBehavior(enable: true)
          : null,
      trackballBehavior: enableTrackball
          ? TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              tooltipSettings: const InteractiveTooltip(
                enable: true,
                format: 'point.x : point.y',
              ),
            )
          : null,
      primaryXAxis: primaryXAxis ?? NumericAxis(
        title: xAxisTitle != null 
            ? AxisTitle(text: xAxisTitle)
            : null,
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: primaryYAxis ?? NumericAxis(
        title: yAxisTitle != null 
            ? AxisTitle(text: yAxisTitle)
            : null,
      ),
      series: series,
    );
  }

  /// Crée un graphique en barres
  static SfCartesianChart createBarChart({
    required List<ChartSeries> series,
    String? title,
    String? xAxisTitle,
    String? yAxisTitle,
    bool showLegend = true,
    bool enableTooltip = true,
    EdgeInsets margin = const EdgeInsets.all(10),
  }) {
    return SfCartesianChart(
      title: title != null 
          ? ChartTitle(text: title)
          : null,
      legend: Legend(
        isVisible: showLegend,
        position: LegendPosition.bottom,
      ),
      margin: margin,
      tooltipBehavior: enableTooltip
          ? TooltipBehavior(enable: true)
          : null,
      primaryXAxis: CategoryAxis(
        title: xAxisTitle != null 
            ? AxisTitle(text: xAxisTitle)
            : null,
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        title: yAxisTitle != null 
            ? AxisTitle(text: yAxisTitle)
            : null,
      ),
      series: series,
    );
  }

  /// Crée un graphique circulaire
  static SfCircularChart createPieChart({
    required List<CircularSeries> series,
    String? title,
    bool showLegend = true,
    bool enableTooltip = true,
    EdgeInsets margin = const EdgeInsets.all(10),
  }) {
    return SfCircularChart(
      title: title != null 
          ? ChartTitle(text: title)
          : null,
      legend: Legend(
        isVisible: showLegend,
        position: LegendPosition.bottom,
      ),
      margin: margin,
      tooltipBehavior: enableTooltip
          ? TooltipBehavior(enable: true)
          : null,
      series: series,
    );
  }
}

// Classe personnalisée pour gérer le gradient dans les séries de lignes
class _LineSeriesRenderer<T> extends LineSeriesRenderer {
  final LineSeries<T, num> series;
  final Color startColor;
  final Color endColor;
  
  _LineSeriesRenderer(this.series, this.startColor, this.endColor);
  
  @override
  void drawSegment(Canvas canvas, Paint paint, List<Offset> points) {
    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [startColor, endColor],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromPoints(points.first, points.last))
      ..strokeWidth = series.width ?? 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(path, gradientPaint);
  }
}