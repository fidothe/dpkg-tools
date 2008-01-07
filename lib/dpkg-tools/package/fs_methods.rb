module DpkgTools
  module Package
    module FSMethods
      def create_dir_if_needed(target_path)
        FileUtils.mkdir_p(target_path) unless File.exists?(target_path)
        raise IOError, "the path '#{target_path}' points to a file, so we can't make a directory there." if File.file?(target_path)
      end
    end
  end
end