class Dashboard < ApplicationRecord
  belongs_to :user

  def calculate_total_time
    return unless start_time && finish_time
    self.total_time = ((finish_time - start_time) / 60).to_i
    save
  end
end
