class RoundRobinTeamSeeder < TeamSeeder
  def rotate_slots
    @slots = [slots[0]] + slots[1..-1].rotate(-1)
    paired_slots.rotate(random_rotation)
  end

  private

  def random_rotation
    1.upto(size/2).map{ |i| i * 2 }.sample
  end

  def paired_slots
    paired_slots = []
    (size/2).times do |i|
      paired_slots << slots[i]
      paired_slots << slots.reverse[i]
    end
    paired_slots
  end
end
