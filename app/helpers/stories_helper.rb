module StoriesHelper
  
  def section_name
    self.plan.section_name if self.plan.present?
  end
  
  def publication_name
    self.plan.pub_name if self.plan.present?
  end
  
end
