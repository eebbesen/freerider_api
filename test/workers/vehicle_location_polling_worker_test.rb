class VehicleLocationPollingWorkerTest < ActiveSupport::TestCase
  MOCK_DATA = [{ "address": 'Grand Ave 1600, 55104 St Paul', "coordinates": [-93.168740, 44.939976, 0], "engineType": 'CE', "exterior": 'GOOD', "fuel": 100, "interior": 'GOOD', "name": 'AAA000', "smartPhoneRequired": false, "vin": 'ABCD0000000000001' },
               { "address": 'W 4th St 90, 55102 St Paul', "coordinates": [-93.097176, 44.944101, 0], "engineType": 'CE', "exterior": 'GOOD', "fuel": 39, "interior": 'GOOD', "name": 'BBB111', "smartPhoneRequired": false, "vin": 'ABCD0000000000002' },
               { "address": 'Snelling Ave N 510, 55104 St Paul', "coordinates": [-93.166811, 44.956653, 0], "engineType": 'CE', "exterior": 'GOOD', "fuel": 21, "interior": 'GOOD', "name": 'CCC222', "smartPhoneRequired": false, "vin": 'ABCD0000000000003' }]

  setup do
    @vehicle_location_polling_worker = VehicleLocationPollingWorker.new
    @mock_caruby2go = MiniTest::Mock.new
    @mock_caruby2go.expect(:vehicles, MOCK_DATA)
  end

  test 'should query car2go and persist records' do
    assert_difference('VehicleLocation.count', 3) do
      Caruby2go.stub(:new, @mock_caruby2go) do
        @vehicle_location_polling_worker.perform('saint_paul')
      end
    end
    assert @mock_caruby2go.verify
  end
end
