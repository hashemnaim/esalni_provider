import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../modules/Map/controller/address_controller.dart';
import '../modules/Profile/controller/profile_controller.dart';
import '../modules/Profile/model/shipping_time_model.dart';
import '../routes/app_pages.dart';
import 'colors.dart';
import 'styles.dart';

String getConvetDate(
  String date1,
) {
  final date = DateTime.parse(date1);
  final date2 = DateTime.now();
  final days = (date2.difference(date).inDays / 30).round();
  final hours = (date2.difference(date).inHours / 24).round();
  final minutes = (date2.difference(date).inMinutes / 60).round();
  String date3 = "";
  if (days > 2) {
    date3 = "منذ ${days.toString()} شهور";
  } else if (hours > 1) {
    date3 = "منذ ${hours.toString()} يوم";
  } else if (minutes > 3) {
    date3 = "منذ ${minutes.toString()} دقائق";
  } else {
    date3 = "منذ لحظات";
  }
  return date3;
}

DateTime dateUtc =
    DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

String getDate(index) {
  return dateUtc.add(Duration(days: index)).day.toString() +
      "/" +
      dateUtc.add(Duration(days: index)).month.toString();
}

String getDay1(index) {
  return dateUtc.add(Duration(days: index)).day.toString();
}

bool getAvalipleEdit(String day, String shippingTimes) {
  String time = shippingTimes.split("-").last;
  log(day);

  if (DateTime.now().day.toString() == day) {
    if (time[0] == '0') {
      log(time[1]);

      return int.parse(time[1]) >
          int.parse(
              (DateTime.now().add(Duration(minutes: 60)).hour).toString());
    } else {
      return int.parse(time) >
          int.parse(DateTime.now().add(Duration(minutes: 0)).hour.toString());
    }
  } else {
    return true;
  }
}

ProfileController profileController = Get.find();
bool getAvaliple(int index, int beforeClose, List<int> count, String day,
    List<ShippingTimes> shippingTimes) {
  log("day " + day.toString());
  log("count " + count.toString());
  log("shippingTimes " + shippingTimes[index].max.toString());
  String time = shippingTimes[index].period!.split("-").last;

  if (shippingTimes[index].avilable == 0) {
    return false;
  } else {
    if (shippingTimes[index].max! <= count[index]) {
      return false;
    } else {
      if (DateTime.now().day.toString() == day.toString()) {
        if (time[0] == '0') {
          return int.parse(time[1]) >
              int.parse(
                  (DateTime.now().add(Duration(minutes: beforeClose)).hour)
                      .toString());
        } else {
          return int.parse(time) >
              int.parse(DateTime.now()
                  .add(Duration(minutes: beforeClose))
                  .hour
                  .toString());
        }
      } else {
        return true;
      }
    }
  }
}

String getPeriod(String time) {
  String time1 = time.split("-").first;
  String time2 = time.split("-").last;

  if (int.parse(time1) >= 12) {
    time1 = int.parse(time1) == 12
        ? time1 + "ض"
        : (int.parse(time1) - 12).toString() + "م";
  } else {
    time1 = time1 + "ص";
  }
  if (int.parse(time2) >= 12) {
    time2 = int.parse(time2) == 12
        ? time2 + "ض"
        : (int.parse(time2) - 12).toString() + "م";
  } else {
    time2 = time2 + "ص";
  }
  return time2 + " - " + time1;
}

changeMyAddress() async {
  return Get.bottomSheet(Container(
    color: Colors.white,
    child: GetBuilder<AddressController>(
      id: "myAddress",
      builder: (controller) => Column(
        children: [
          Container(
            height: 50.h,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: Text(
                "اختر عنوانك",
                style: Style.cairo
                    .copyWith(fontSize: 16, color: AppColors.bluColor),
              ),
            ),
          ),
          Expanded(
            child: controller.addressModel.data == null
                ? Container()
                : ListView.builder(
                    itemCount: controller.addressModel.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                              title: Text(
                                controller.addressModel.data![index].street ??
                                    "",
                                style: Style.cairog.copyWith(
                                    fontSize: 18.sp,
                                    color: controller.addressModel.data![index]
                                                .isDefault ==
                                            1
                                        ? AppColors.greenColor
                                        : AppColors.bluColor),
                              ),
                              subtitle: Text(
                                controller.addressModel.data![index].city! +
                                    "_" +
                                    controller.addressModel.data![index].area!,
                                style: Style.cairog.copyWith(
                                    fontSize: 14.sp,
                                    color: controller.addressModel.data![index]
                                                .isDefault ==
                                            1
                                        ? AppColors.greenColor
                                        : AppColors.bluColor),
                              ),
                              onTap: controller.addressModel.data![index]
                                          .isDefault ==
                                      1
                                  ? null
                                  : () async {
                                      await controller.editAddrees(
                                          1,
                                          controller
                                              .addressModel.data![index].id);
                                      Get.back();
                                    },
                              minLeadingWidth: 1,
                              leading: Icon(Icons.location_on_outlined,
                                  size: 29,
                                  color: controller.addressModel.data![index]
                                              .isDefault ==
                                          1
                                      ? AppColors.greenColor
                                      : AppColors.bluColor),
                              trailing: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.greenColor)),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    height: 25.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: controller.addressModel
                                                  .data![index].isDefault ==
                                              1
                                          ? AppColors.greenColor
                                          : Colors.white,
                                    ),
                                    child: Checkbox(
                                        shape: CircleBorder(),
                                        value: controller.addressModel
                                                    .data![index].isDefault ==
                                                1
                                            ? true
                                            : false,
                                        activeColor: AppColors.greenColor,
                                        splashRadius: 20,
                                        onChanged: (value) async {
                                          await controller.editAddrees(
                                              1,
                                              controller.addressModel
                                                  .data![index].id);
                                          Get.back();
                                        }),
                                  ),
                                ),
                              )));
                    }),
          ),
          Center(
            child: Container(
              width: 300.w,
              child: TextButton(
                  child: Text(
                    "اضافة عنوان جديد",
                    style: Style.cairo
                        .copyWith(fontSize: 16.sp, color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.greenColor),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(
                      Routes.AddAddressScreen,
                    );
                  }),
            ),
          ),
          SizedBox(
            height: 10.h,
          )
        ],
      ),
    ),
  ));
}
