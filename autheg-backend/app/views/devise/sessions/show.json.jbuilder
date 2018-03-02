if user_signed_in?
  json.(current_user, :id, :email)
end
