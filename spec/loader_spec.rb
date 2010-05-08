require File.dirname(__FILE__) + "/spec_helper"

describe Aegis::Loader do

  describe 'paths' do

    it "should return all paths in the lib folder" do

      root = "#{File.dirname(__FILE__)}/../lib/"
      expected_paths = Dir["#{root}*/*.rb"].collect do |file|
        file.sub(root, "").sub(/\.rb$/, "")
      end - ['aegis/loader']

      Aegis::Loader.paths.should =~ expected_paths

    end

  end

end