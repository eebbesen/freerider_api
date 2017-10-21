##
# Mockish thing to simulate DropboxClient
class TestDropboxClient
  attr_reader :filename, :file, :token, :data

  File = Struct.new(:name)
  # @name="amsterdam-20170922_010148", @path_lower="/amsterdam-20170922_010148", @path_display="/amsterdam-20170922_010148", @id="id:DKUKj93cNSAAAAAAAASXyw", @client_modified=2017-09-22 01:01:48 UTC, @server_modified=2017-09-22 01:01:48 UTC, @rev="b12df4462d7a0", @size=77536, @content_hash="32dbb5ebf5e291846a5614b9e6672648983d57d744806c83f8d7cf087d9f4caa", @media_info=nil
  Results = Struct.new(:has_more?, :cursor, :entries)

  def initialize(token)
    @token = token
    @data = '[{"address"=>"W 4th St 90, 55102 Saint Paul", "coordinates"=>[-93.097112, 44.944025, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>36, "interior"=>"GOOD", "name"=>"AB5102", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME000"}, {"address"=>"Marshal Ave 1831, 55104 Saint Paul", "coordinates"=>[-93.177645, 44.949533, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>66, "interior"=>"GOOD", "name"=>"AB5104", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME001"}, {"address"=>"Ford Pkway 1974, 55116 Saint Paul", "coordinates"=>[-93.183036, 44.917769, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>18, "interior"=>"GOOD", "name"=>"AB7740", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME002"}]'
  end

  def upload(filename, file)
    @filename = filename
    @file = file
  end

  def destroyed_files
    @destroyed_files ||= []
  end

  def list_folder(_path)
    Results.new(false,
                'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE',
                [File.new('/amsterdam-20160103_222646'), File.new('/arlingtoncounty-20160103_222649')])
  end

  def get_file(_filename)
    @data
  end

  def delete(filename)
    destroyed_files << filename
  end

  attr_writer :data
end
