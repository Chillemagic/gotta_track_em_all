module ApplicationHelper
  def responsive_visibility_class(index)
    case index
    when 0 then 'flex flex-col items-center'
    when 1 then 'hidden md:flex md:flex-col md:items-center'
    when 2 then 'hidden lg:flex lg:flex-col lg:items-center'
    when 3 then 'hidden xl:flex xl:flex-col xl:items-center'
    end
  end
end
