
module WflFileBase
	class Base
		attr_accessor :column, :model, :file, :store

		def initialize column, model
			self.column = column
			self.model = model
			self.store = false
			if model.read_attribute(column).is_a? File
				self.file = model.read_attribute(column)
			elsif model.read_attribute(column).is_a? Tempfile
				self.file = model.read_attribute(column)
			elsif model.read_attribute(column).is_a?(Hash) && model.read_attribute(column)[:tempfile].is_a?(Tempfile)
				self.file = model.read_attribute(column)[:tempfile]
			elsif self.filename.is_a?(String) && !self.filename.empty? && File.exist?(self.path)
				self.file = File.open(self.path)
			end
		end

		def store_dir
			model.id
		end

		def filename
			'original'
		end

		def path
			"#{WflFileBase.config.root}#{self.url}"
		end

		def url
			"#{self.store_dir}/#{self.filename}"
		end

		def abs_store_dir
			"#{WflFileBase.config.root}#{self.store_dir}"
		end


		def read
			if file && !File.directory?(file)
				file.send(:read)
			else
				nil
			end
		end

		def method_missing(method, *args)
			if file
				file.methods.include?(method) ? file.send(method, *args) : super
			end
		end

		def respond_to? method
			file.methods.include?(method) || super
		end

		def is_new?
			model.read_attribute(column).is_a?(File) || model.read_attribute(column).is_a?(Tempfile) || (model.read_attribute(column).is_a?(Hash) && model.read_attribute(column)[:tempfile].is_a?(Tempfile))
		end

		class << self
			attr_reader :wfl_process_methods, :wfl_pre_process_methods

			def process method_name
				@wfl_process_methods ||= []
				@wfl_process_methods.push method_name
			end

			def pre_process method_name
				@wfl_pre_process_methods ||= []
				@wfl_pre_process_methods.push method_name
			end
		end

		private

		def write_column
			self.store = true
			model.send(:write_attribute, :"#{column}", self.filename)
			delete_old_file
			if self.class.wfl_pre_process_methods
				self.class.wfl_pre_process_methods.each do |process_method|
					self.send(process_method)
				end
			end
		end

		def build_file
			FileUtils.mkdir_p(abs_store_dir) unless File.exists?(abs_store_dir)
			temple_file = self.file
			if temple_file.is_a?(Tempfile)
				FileUtils.copy(tmpfile_to_file(temple_file), path)
				File.delete(tmp_file_path) if File.exists?(tmp_file_path)
			elsif temple_file.is_a?(Hash) && temple_file[:tempfile].is_a?(Tempfile)
				FileUtils.copy(tmpfile_to_file(temple_file[:tempfile]), path)
				File.delete(tmp_file_path) if File.exists?(tmp_file_path)
			elsif temple_file.is_a?(File) && File.directory?(temple_file)
				FileUtils.mkdir_p(path)
			elsif temple_file.is_a?(File)
				FileUtils.copy temple_file, path
			else
				return nil
			end

			self.file = File.open(path)

			if self.class.wfl_process_methods
				self.class.wfl_process_methods.each do |process_method|
					self.send(process_method)
				end
			end
			self.store = false
		end

		def delete_old_file
			if !model.new_record? && !model.send(:"#{column}_was").nil? && !model.send(:"#{column}_was").empty?
				File.delete(path_was) if File.exist?(path_was) && !File.directory?(path_was)
			end
		end

		def path_was
			"#{WflFileBase.config.root}#{self.store_dir}/#{self.filename_was}"
		end

		def remove_file
			if File.exist?(file) && File.directory?(file)
				FileUtils.remove_dir file
			elsif File.exist?(file) 
				File.delete file
			end
		end

		def tmpfile_to_file file
			if file.is_a? Tempfile
				FileUtils.mkdir_p(tmp_file_dir) unless File.exists?(tmp_file_dir)
				File.delete(tmp_file_path) if File.exists?(tmp_file_path)
				file.rewind
				File.open(tmp_file_path, 'wb') do |f|
					f.write(file.read)
				end
				File.open(tmp_file_path)
			end
		end

		def tmp_file_path
			"#{tmp_file_dir}/#{tmp_file_name}"
		end

		def tmp_file_name
			@uu_name ||= SecureRandom.uuid
		end

		def tmp_file_dir
			"#{WflFileBase.config.root}#{WflFileBase.config.tmp_dir}"
		end

	end

end