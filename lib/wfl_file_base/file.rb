

module WflMimeType
	def self.included(base)
		base.extend ClassMethods
		base.class_eval do 
		    def mime_type
		        `file --brief --mime-type #{self.path}`.strip
		    end

		    def charset
		        `file --brief --mime #{self.path}`.split(';').second.split('=').second.strip
		    end
		end
	end

	module ClassMethods
		def mime_type file
			if file.is_a?(String) && File.exist?(file)
				file = File.open(file)
				`file --brief --mime-type #{file.path}`.strip
			elsif (file.is_a?(File) && !File.directory?(file))
				`file --brief --mime-type #{file.path}`.strip
			else
				raise 'the path is useless or the file is useless'
			end
		end

		def charset
			if file.is_a?(String) && File.exist?(file)
				file = File.open(file)
				`file --brief --mime #{file.path}`.split(';').second.split('=').second.strip
			elsif (file.is_a?(File) && !File.directory?(file))
				`file --brief --mime #{file.path}`.split(';').second.split('=').second.strip
			else
				raise 'the path is useless or the file is useless'
			end
		end
	end
end

class File
	include WflMimeType
end