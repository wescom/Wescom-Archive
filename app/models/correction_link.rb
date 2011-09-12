class CorrectionLink < ActiveRecord::Base
  belongs_to :story
  belongs_to :correction, :class_name => 'Story'
end
