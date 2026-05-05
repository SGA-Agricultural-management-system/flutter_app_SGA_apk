import '../models/farm_model.dart';

class FarmService {
  Future<List<FarmModel>> getFarms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [getMockFarm()];
  }

  Future<FarmModel> getFarmById(String id) async {
    return getMockFarm();
  }

  Future<List<LotModel>> getLots(String farmId) async {
    return getMockFarm().lots;
  }

  Future<SensorDataModel> getSensorData(String farmId) async {
    return SensorDataModel.mock();
  }

  FarmModel getMockFarm() => FarmModel(
    id: 'farm1',
    name: 'Finca La Esperanza',
    location: 'Bucaramanga, Santander',
    lots: [
      LotModel(id: 'lot1', name: 'Lote A',      crop: 'Maíz'),
      LotModel(id: 'lot2', name: 'Lote B',      crop: 'Tomate'),
      LotModel(id: 'lot3', name: 'Invernadero 1', crop: 'Lechuga'),
    ],
  );
}
