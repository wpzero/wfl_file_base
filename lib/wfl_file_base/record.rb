class << ActiveRecord::Base
	def wfl_mount_file_base column, uploader_class

		self.class_eval do

			define_method column.to_sym do
				@uploader ||= uploader_class.new(column, self)
			end

			define_method "write_#{column}" do
				if self.send("#{column}_changed?") && (self.read_attribute(column).is_a?(File) || (self.read_attribute(column).is_a?(Hash) && self.read_attribute(column)[:tempfile].is_a?(Tempfile)) || self.read_attribute(column).is_a?(Tempfile))
					self.send(column).send(:write_column)
				end
			end

			define_method "store_#{column}" do
				if self.send(column).store
					self.send(column).send(:build_file)
				end
			end

			define_method "remove_#{column}" do
				self.send(column).send(:remove_file)
			end

		end
		self.after_save :"store_#{column}"
		self.before_save :"write_#{column}"
		self.after_commit :"remove_#{column}", :on => :destroy
	end

end