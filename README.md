# WflFileBase

this gem is used to map a file to a record based on the activerecord.
this gem is very simple and small. but I think it can fit most the requests of u.
this gem is similar to carrierwave. I must admit 'yes'
before I write this gem, I use the carrierwave in my project, my project has the function network disk. but the carrierwave can not bind the folder to a record(so not fit my request and the carrier is too fat).so I write a gem.

## Installation

Add this line to your application's Gemfile:

    gem 'wfl_file_base'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wfl_file_base

## Usage

in application.rb

```
WflFileBase.configure do |config|
  config.root = APP_ROOT + '/public/'
  config.tmp_dir = 'tmp'
end
```
is used to set the tmp_dir and the application root folder.




create WflFileBase::Base subclass and override the filename ,  dir_name the method, to set the file location.

such as:

```
require 'digest/md5'
require 'carrierwave/processing/mime_types'
require_relative '../services/file_system/file_path_setting'
require_relative '../services/file_system/base/md5_process'

class NormalFileBase < WflFileBase::Base

  pre_process :save_content_type_and_size_in_model

  def store_dir
    FileSys::FilePathSetting.resource_path + '/' + md5init
  end

  def filename
      @name ||= md5
  end

  def filename_was
      model.send(:"#{column}_was")
  end

  def md5
  	# creat process
  	if self.store
      puts '---------new'
      file.rewind
  		@md5 ||= FileSys::Md5Process.send(:get_md5_name, :content => file.read.to_s, :size => file.size.to_s)
  	# read process
  	else
      puts '---------old'
  		model.read_attribute(column)
  	end
  end

  def md5init
  	md5[0].upcase
  end

  def save_content_type_and_size_in_model
    model.content_type = file.mime_type if file.mime_type
    model.file_size = file.size
  end
end
```


store method is used to check whether in store process.
pre_process macro can pass symbol variable to identify the method which will be called before the save process.
process macro can pass symbol variable to identify the method which will be called after the save process.


use wfl_mount_file_base activereord macro to bind column and WflFileBase::Base subclass.

such as:

```
require_relative 'md5_process'

module FileSys
	class FileResource < ActiveRecord::Base

		wfl_mount_file_base :file, NormalFileBase

		before_save :update_file_attributes

		class << self
			def find_or_create_file_resource file
				file=file[:tempfile] if file.is_a?(Hash) && file[:tempfile].is_a?(Tempfile)
				file.rewind
				file_resource = self.find_by_file(Md5Process.get_md5_name(:content => file.read.to_s, :size => file.size.to_s))
				if !file_resource
					file_resource = FileSys::FileResource.create(:file => file)
				end
				file_resource
			end

			def find_by_path url
				find_by_file File.basename(url)
			end
		end

		def read
			file.read
		end
		
		private
		def update_file_attributes
		    if file.present?
		      self.md5_val  = file.md5
		    end
		end
	end
end
```



now we can use FileSys::FileResource simplely.



```
f = FileSys::FileResource.new
f.file = File.open('tmp.txt')
f.save
f.file   =># <SymbleFileBase>
f.file.file =># <File>
f.file.read =># <String>
```








## Contributing

1. Fork it ( https://github.com/[my-github-username]/wfl_file_base/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
