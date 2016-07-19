require_relative "../../../lib/pra/config"

describe Pra::Config do
  describe "#initialize" do
    it "assigns the provide default config hash" do
      config_hash = { some: "hash" }
      config = Pra::Config.new(config_hash)
      expect(config.instance_variable_get(:@initial_config)).to eq(config_hash)
    end
  end

  describe ".load_config" do
    subject { described_class }

    it "parses the config file" do
      expect(subject).to receive(:parse_config_file).and_return({})
      subject.load_config
    end

    it "constructs an instance of the config from the parsed config" do
      parsed_config = double('parsed config file')
      allow(subject).to receive(:parse_config_file).and_return(parsed_config)
      expect(subject).to receive(:new).with(parsed_config)
      subject.load_config
    end

    it "returns the instance of the config object" do
      allow(subject).to receive(:parse_config_file)
      config = double('config')
      allow(subject).to receive(:new).and_return(config)
      expect(subject.load_config).to eq(config)
    end
  end

  describe ".parse_config_file" do
    subject { described_class }

    it "reads the users config" do
      allow(subject).to receive(:json_parse)
      expect(subject).to receive(:read_config_file)
      subject.parse_config_file
    end

    it "json parses the config contents" do
      config_contents = double('config contents')
      allow(subject).to receive(:read_config_file).and_return(config_contents)
      expect(subject).to receive(:json_parse).with(config_contents)
      subject.parse_config_file
    end
  end

  describe ".read_config_file" do
    subject { described_class }

    it "opens the file" do
      config_path = double('config path')
      allow(subject).to receive(:config_path).and_return(config_path)
      expect(File).to receive(:open).with(config_path, "r").and_return(double('config file').as_null_object)
      subject.read_config_file
    end

    it "reads the files contents" do
      allow(subject).to receive(:config_path)
      file = double('config file').as_null_object
      allow(File).to receive(:open).and_return(file)
      expect(file).to receive(:read)
      subject.read_config_file
    end

    it "closes the file" do
      allow(subject).to receive(:config_path)
      file = double('config file', read: nil)
      allow(File).to receive(:open).and_return(file)
      expect(file).to receive(:close)
      subject.read_config_file
    end

    it "returns the file contents" do
      allow(subject).to receive(:config_path)
      file = double('config file', close: nil)
      allow(File).to receive(:open).and_return(file)
      allow(file).to receive(:read).and_return('some file contents')
      expect(subject.read_config_file).to eq('some file contents')
    end
  end

  describe ".config_path" do
    subject { Pra::Config }

    it "returns the joined users home directory and .pra.json to create the path" do
      allow(subject).to receive(:users_home_directory).and_return('/home/someuser')
      expect(subject.config_path).to eq('/home/someuser/.pra.json')
    end
  end

  describe ".log_path" do
    subject { described_class }

    it "returns the joined users home directory and .pra.log to create the path" do
      allow(Dir).to receive(:exists?).and_return(true)
      allow(ENV).to receive(:[]).with("HOME").and_return('/home/someuser')
      expect(subject.log_path).to eq('/home/someuser/.pra/logs/.pra.log')
    end
  end

  describe ".users_home_directory" do
    subject { described_class }

    it "returns the current users home directory" do
      ENV['HOME'] = '/home/someuser'
      expect(subject.users_home_directory).to eq('/home/someuser')
    end
  end

  describe ".json_parse" do
    subject { described_class }

    it "parses the given content as json" do
      content = double('some json content')
      expect(JSON).to receive(:parse).with(content)
      subject.json_parse(content)
    end

    it "returns the parsed result" do
      parsed_json = double('the parsed json')
      allow(JSON).to receive(:parse).and_return(parsed_json)
      expect(subject.json_parse(double)).to eq(parsed_json)
    end
  end

  describe "#pull_sources" do
    it "returns the pull sources value out of the config" do
      pull_source_configs = double('pull source configs')
      subject.instance_variable_set(:@initial_config, { "pull_sources" => pull_source_configs })
      expect(subject.pull_sources).to eq(pull_source_configs)
    end
  end

  describe "#assignee_blacklist" do
    context 'when config has an assignee blacklist' do
      it "returns the assignee blacklist value out of the config" do
        assignee_blacklist_configs = [double('assignee blacklist configs')]
        subject.instance_variable_set(:@initial_config, { "assignee_blacklist" => assignee_blacklist_configs })
        expect(subject.assignee_blacklist).to eq(assignee_blacklist_configs)
      end
    end

    context "when config does not have an assignee blacklist" do
      it "returns an empty array" do
        subject.instance_variable_set(:@initial_config, {})
        expect(subject.assignee_blacklist).to eq([])
      end
    end
  end
end
