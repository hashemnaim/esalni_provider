import 'package:bot_toast/bot_toast.dart';
import 'package:capotcha/modules/Profile/controller/profile_controller.dart';
import 'package:capotcha/widgets/custom_drop_down.dart';
// import 'package:capotcha/modules/Profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../services/api_call_status.dart';
import '../../../services/base_client.dart';
import '../../../utils/constants.dart';
import '../../../utils/shared_preferences_helpar.dart';
import '../model/address_model.dart';
import 'map_controller.dart';

class AddressController extends GetxController {
  Set<Marker>? markersset;
  MapController mapController = Get.find();
  Rx<int> isDefulte = 1.obs;
  Rx<bool> isLoad = false.obs;
  Rx<Item> area = Item(id: 0, name: "اختر المنطق").obs;
  Rx<Item> city = Item(id: 0, name: "اختر المدينة").obs;
  Rx<String> wordBuildValue = "".obs;

  List<String>? wordBuild = [
    "أ",
    "ب",
    "ص",
    "ج",
    "ز",
    "ع",
    "و",
    "م",
    "ل",
    "ط",
    "و",
    "ن",
    "ل",
    "ك",
    "د",
    "ه",
    "ح",
    "د"
  ];
  Rx<CitiesModel> citiesModel = CitiesModel().obs;
  Rx<CitiesModel> areaModel = CitiesModel().obs;
  ApiCallStatus addressStatus = ApiCallStatus.holding;
  AddressModel addressModel = AddressModel();
  DataAddress dataAddress = DataAddress();
  bool addLocation = false;
  ProfileController profileController = Get.find();

  getCities() async {
    await BaseClient.baseClient.get(Constants.citiesApiUrl,
        onSuccess: (response) {
      citiesModel.value = CitiesModel.fromJson(response.data);
    });
  }

  getArea(String id) async {
    isLoad.value = true;
    await BaseClient.baseClient.post(Constants.areaApiUrl,
        data: {"city_id": id}, onSuccess: (response) {
      areaModel.value = CitiesModel.fromJson(response.data);
      isLoad.value = false;
    });
  }

  ///Server
  deleteAddrees(int? id) async {
    BotToast.showLoading();
    await BaseClient.baseClient.post(Constants.deleteAddressUrl,
        data: {"address_id": id}, onSuccess: (response) {
      if (response.data['code'] == 401) {
        // addressModel.data.removeWhere((element) => element.id == id);
        profileController.getProfile();

        getMyAddress();
        BotToast.closeAllLoading();
      } else {
        BotToast.showText(
            text: response.data['message'], contentColor: Colors.red);
        BotToast.closeAllLoading();
      }
    });
  }

  clean() {
    area = Item(id: 0, name: "اختر المنطق").obs;
    city = Item(id: 0, name: "اختر المدينة").obs;
    mapController.noBuildControlelr.clear();
    mapController.noFloorControlelr.clear();
    mapController.addressControlelr.clear();
  }

  addAddrees(int isDefault, String? phone) async {
    await BaseClient.baseClient.post(Constants.addAddressUrl, data: {
      "phone": phone,
      "is_default": isDefault,
      "street": mapController.addressControlelr.value.text,
      "apartment": mapController.noFloorControlelr.value.text +
          "-" +
          mapController.noFloorControlelr.value.text,
      "building": mapController.noBuildControlelr.value.text +
          " " +
          wordBuildValue.value,
      "lat": mapController.position.latitude,
      "lng": mapController.position.longitude,
      "city_id": city.value.id,
      "area_id": area.value.id
    }, onSuccess: (response) {
      if (response.data['code'] == 200) {
        profileController.getProfile();

        getMyAddress();

        BotToast.showText(
          text: "تم اضافة العنوان بنجاج",
        );
        clean();
        Get.back();
      } else {
        BotToast.showText(
            text: response.data['message'], contentColor: Colors.red);
      }
    });
  }

  editAddrees(int isDefault, int? idAddress) async {
    addressStatus = ApiCallStatus.loading;
    BotToast.showLoading();
    await BaseClient.baseClient.post(Constants.addAddressUrl,
        data: {"is_default": isDefault, "address_id": idAddress},
        onSuccess: (response) {
      if (response.data['code'] == 200) {
        BotToast.showText(
          text: "اصبح العنوان الافتراضي",
        );
        profileController.getProfile();

        getMyAddress();
        BotToast.closeAllLoading();

        addressStatus = ApiCallStatus.success;
      } else {
        BotToast.showText(
            text: response.data['message'], contentColor: Colors.red);
      }
    });
  }

  getMyAddress() async {
    if (SHelper.sHelper.getToken() == null) {
    } else {
      addressStatus = ApiCallStatus.loading;
      await BaseClient.baseClient.get(Constants.myAddressesUrl,
          onSuccess: (response) {
        addressModel = AddressModel.fromJson(response.data);
        addressStatus = ApiCallStatus.success;
        update(['myAddress']);
      });
    }
  }

  @override
  void onInit() {
    getCities();
    getMyAddress();
    super.onInit();
  }
}
