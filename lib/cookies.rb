module Cookies
  def save_cookies(params)
    cookies[:group_number] = params[:group_number]
    cookies[:subgroup_number] = params[:subgroup_number]
  end

  def load_cookies
    {
      group_number: cookies[:group_number] || nil,
      subgroup_number: cookies[:subgroup_number] || 1
    }
  end

  def cookies_present?
    if cookies[:group_number].present? and cookies[:subgroup_number].present?
      return true
    end
    false
  end

  def reset_cookies
    cookies[:group_number] = nil
    cookies[:subgroup_number] = 1
  end
end