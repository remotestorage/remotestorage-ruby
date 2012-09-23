class App < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user_id, :name, :start_url

  def build_start_url(params)
    start_url + start_fragment(params)
  end

  private

  def start_fragment(params)
    "##{encoded_fragment_params(params)}"
  end

  def encoded_fragment_params(params)
    params.each_pair.map do |k, v|
      "#{k}=#{URI.encode_www_form_component(v)}"
    end.join('&')
  end

end
