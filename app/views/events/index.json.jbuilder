json.array!(@events) do |event|
  json.extract! event, :id, :action, :user, :otheruser, :message, :date
  json.url event_url(event, format: :json)
end
