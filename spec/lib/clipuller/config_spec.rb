require_relative "../../../lib/clipuller/config"

describe Clipuller::Config do
  describe "#initialize" do
    it "assigns the provide default config hash" do
      config_hash = { some: "hash" }
      config = Clipuller::Config.new(config_hash)
      config.instance_variable_get(:@initial_config).should eq(config_hash)
    end
  end

  describe ".load_config" do
    subject { Clipuller::Config }

    it "parses the config file" do
      subject.should_receive(:parse_config_file)
      subject.load_config
    end

    it "constructs an instance of the config from the parsed config" do
      parsed_config = double('parsed config file')
      subject.stub(:parse_config_file).and_return(parsed_config)
      subject.should_receive(:new).with(parsed_config)
      subject.load_config
    end

    it "returns the instance of the config object" do
      subject.stub(:parse_config_file)
      config = double('config')
      subject.stub(:new).and_return(config)
      subject.load_config.should eq(config)
    end
  end

  describe ".parse_config_file" do
    subject { Clipuller::Config }

    it "reads the users config" do
      subject.stub(:json_parse)
      subject.should_receive(:read_config_file)
      subject.parse_config_file
    end

    it "json parses the config contents" do
      config_contents = double('config contents')
      subject.stub(:read_config_file).and_return(config_contents)
      subject.should_receive(:json_parse).with(config_contents)
      subject.parse_config_file
    end
  end

  describe ".read_config_file" do
    subject { Clipuller::Config }

    it "opens the file" do
      config_path = double('config path')
      subject.stub(:config_path).and_return(config_path)
      File.should_receive(:open).with(config_path, "r").and_return(double('config file').as_null_object)
      subject.read_config_file
    end

    it "reads the files contents" do
      subject.stub(:config_path)
      file = double('config file').as_null_object
      File.stub(:open).and_return(file)
      file.should_receive(:read)
      subject.read_config_file
    end

    it "closes the file" do
      subject.stub(:config_path)
      file = double('config file', read: nil)
      File.stub(:open).and_return(file)
      file.should_receive(:close)
      subject.read_config_file
    end

    it "returns the file contents" do
      subject.stub(:config_path)
      file = double('config file', close: nil)
      File.stub(:open).and_return(file)
      file.stub(:read).and_return('some file contents')
      subject.read_config_file.should eq('some file contents')
    end
  end

  describe ".config_path" do
    subject { Clipuller::Config }

    it "returns the joined users home directory and .clipuller.json to create the path" do
      subject.stub(:users_home_directory).and_return('/home/someuser')
      subject.config_path.should eq('/home/someuser/.clipuller.json')
    end
  end

  describe ".users_home_directory" do
    subject { Clipuller::Config }

    it "returns the current users home directory" do
      ENV['HOME'] = '/home/someuser'
      subject.users_home_directory.should eq('/home/someuser')
    end
  end

  describe ".json_parse" do
    subject { Clipuller::Config }

    it "parses the given content as json" do
      content = double('some json content')
      JSON.should_receive(:parse).with(content)
      subject.json_parse(content)
    end

    it "returns the parsed result" do
      parsed_json = double('the parsed json')
      JSON.stub(:parse).and_return(parsed_json)
      subject.json_parse(double).should eq(parsed_json)
    end
  end

  describe "#pull_sources" do
    it "returns the pull sources value out of the config" do
      pull_source_configs = double('pull source configs')
      subject.instance_variable_set(:@initial_config, { "pull_sources" => pull_source_configs })
      subject.pull_sources.should eq(pull_source_configs)
    end
  end
end
