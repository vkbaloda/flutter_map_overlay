import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const metersInPixels = 252.0864; //100 pixel in meters for zoom = 16

class MapOverlayWidgetContainer {
  final Offset offset;
  final LatLng position;
  final Widget child;
  final Size imgSizeInMeters;

  MapOverlayWidgetContainer({
    @required this.child, //is expected to have size according to zoom = 16
    @required this.position,
    this.offset = Offset.zero,
    @required this.imgSizeInMeters,
  });

  Widget build(
    BuildContext context,
    LatLngBounds bounds,
    CameraPosition cameraPosition,
    Size screenSize,
  ) {
    //get display size of img in zoom 16
    final imgSize = Size(
      imgSizeInMeters.width * 100 / metersInPixels,
      imgSizeInMeters.height * 100 / metersInPixels,
    );

    //get screen to latlng ratio
    final targetNE = bounds.northeast;
    final targetSW = bounds.southwest;

    final screenDiff = LatLng(
      targetSW.latitude - targetNE.latitude,
      targetSW.longitude - targetNE.longitude,
    );
    //get map screen size
    // final mediaQueryData = MediaQuery.of(context);
    // final size = Size(
    //   mediaQueryData.size.width -
    //       (mediaQueryData.viewInsets.left + mediaQueryData.viewInsets.right),
    //   mediaQueryData.size.height -
    //       (mediaQueryData.viewInsets.top + mediaQueryData.viewInsets.bottom),
    // );
    final imgZoomScale = pow(2, cameraPosition.zoom - 16);
    //img display position calculation
    final imgCenterPosRatio = Point(
      ((targetSW.longitude - position.longitude) / screenDiff.longitude),
      ((targetNE.latitude - position.latitude) / -screenDiff.latitude),
    );
    //offset shouldn't be needed though
    final displayPosition = Point(
      (imgCenterPosRatio.x * screenSize.width) -
          offset.dx -
          (imgSize.width * imgZoomScale / 2),
      (imgCenterPosRatio.y * screenSize.height) -
          offset.dy -
          (imgSize.height * imgZoomScale / 2),
    );
    if (displayPosition.y < -10 ||
        displayPosition.x < -10 ||
        displayPosition.y > screenSize.height + 10 ||
        displayPosition.x > screenSize.width + 10) return null;

    return Positioned(
      top: displayPosition.y,
      left: displayPosition.x,
      child: Align(
        alignment: Alignment(0, 0
            // imgCenterPosRatio.x * 2 - 1,
            // imgCenterPosRatio.y * 2 - 1,
            ),
        child: Transform.scale(
          scale: imgZoomScale,
          child: Transform.rotate(
            angle: -cameraPosition.bearing * pi / 180,
            child: child,
          ),
        ),
      ),
    );
  }
}
