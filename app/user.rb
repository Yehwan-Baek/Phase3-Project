class User < ActiveRecord::Base
    has_many :headlines
end