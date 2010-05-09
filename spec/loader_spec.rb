require File.dirname(__FILE__) + "/spec_helper"

describe Aegis::Loader do

  describe 'paths' do

    it "should return all paths in the lib folder" do

      root = "#{File.dirname(__FILE__)}/../lib/"
      Dir["#{root}*/*.rb"].collect do |file|
        path = file.sub(root, "").sub(/\.rb$/, "")
        Aegis::Loader.paths.should include(path) unless path == 'aegis/loader'
      end

    end

  end

  describe 'loaded?' do

    it "should be loaded" do
      Aegis::Loader.should be_loaded
    end

  end

end