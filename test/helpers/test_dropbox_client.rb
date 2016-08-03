##
# Mockish thing to simulate DropboxClient
class TestDropboxClient
  attr_reader :filename, :file, :token, :data

  def initialize(token)
    @token = token
    @data = '[{"address"=>"W 4th St 90, 55102 Saint Paul", "coordinates"=>[-93.097112, 44.944025, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>36, "interior"=>"GOOD", "name"=>"AB5102", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME000"}, {"address"=>"Marshal Ave 1831, 55104 Saint Paul", "coordinates"=>[-93.177645, 44.949533, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>66, "interior"=>"GOOD", "name"=>"AB5104", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME001"}, {"address"=>"Ford Pkway 1974, 55116 Saint Paul", "coordinates"=>[-93.183036, 44.917769, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>18, "interior"=>"GOOD", "name"=>"AB7740", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME002"}]'
  end

  def put_file(filename, file)
    @filename = filename
    @file = file
  end

  def destroyed_files
    @destroyed_files ||= []
  end

  def delta
    { 'has_more' => true,
      'cursor' => 'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE',
      'entries' => [['/amsterdam-20160103_222646', { 'rev' => '5413a6ecb', 'thumb_exists' => false, 'path' => '/amsterdam-20160103_222646', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'icon' => 'page_white', 'bytes' => 87_200, 'modified' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'size' => '85.2 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 5 }], ['/arlingtoncounty-20160103_222649', { 'rev' => '6413a6ecb', 'thumb_exists' => false, 'path' => '/arlingtoncounty-20160103_222649', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'icon' => 'page_white', 'bytes' => 19_389, 'modified' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'size' => '18.9 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 6 }]],
      'reset' => true }
  end

  def get_file(_filename)
    @data
  end

  def file_delete(filename)
    destroyed_files << filename
  end

  attr_writer :data
end
