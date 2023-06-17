import 'package:flutter/material.dart';

enum DeviceType {
  mobileSmall,
  mobileMedium,
  mobileLarge,
  tabletSmall,
  tabletMedium,
  tabletLarge,
  desktopSmall,
  desktopMedium,
  desktopLarge,
  desktopXLarge,
  desktop2XLarge,
  desktop3XLarge,
  desktop4XLarge,
  other
}

DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width < 600) {
    // Mobil
    if (width < 360) {
      return DeviceType.mobileSmall;
    } else if (width < 480) {
      return DeviceType.mobileMedium;
    } else {
      return DeviceType.mobileLarge;
    }
  } else if (width < 900) {
    // Tablet
    if (width < 600) {
      return DeviceType.tabletSmall;
    } else if (width < 768) {
      return DeviceType.tabletMedium;
    } else {
      return DeviceType.tabletLarge;
    }
  } else if (width < 3840) {
    // Desktop
    if (width < 992) {
      return DeviceType.desktopSmall;
    } else if (width < 1140) {
      return DeviceType.desktopLarge;
    }
    else if (width < 2208) {
      return DeviceType.desktopXLarge;
    }
    else if (width < 2560) {
      return DeviceType.desktop2XLarge;
    }
    else if (width < 2880) {
      return DeviceType.desktop3XLarge;
    }
    else {
      return DeviceType.desktop4XLarge;
    }
  }


  return DeviceType.other;
}
