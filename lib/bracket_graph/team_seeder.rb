class TeamSeeder
  attr_reader :size

  def initialize teams, size, shuffle: false
    @teams = shuffle && teams.shuffle || teams.dup
    @size = size
  end

  def slots
    return @slots if @slots
    @slots = [true] * size
    seed_byes
    seed_teams
    @slots
  end

  private

  def seed_byes
    byes_to_seed = size - @teams.length
    return if byes_to_seed == 0
    @slots[0] = nil
    seed_byes_by_partition byes_to_seed - 1 if byes_to_seed > 1
  end

  def seed_teams
    @slots.each_with_index do |slot_value, index|
      @slots[index] = @teams.shift if slot_value == true
    end
  end

  def seed_byes_by_partition byes
    partition = nil
    byes.times do
      partition = largest_bye_partition
      mid_index = partition.min + ((partition.max.to_f - partition.min) / 2).ceil
      @slots[mid_index] = nil
    end
  end

  def largest_bye_partition
    start_index, end_index = nil, nil
    prev_index = 0
    @slots.each_with_index do |value, index|
      next if index > 0 && index < @slots.count - 1 && value
      if start_index.nil?
        start_index = index
      elsif end_index.nil?
        end_index = index
      elsif index - prev_index > end_index - start_index
        start_index, end_index = prev_index, index
      end
      prev_index = index
    end
    Range.new start_index, end_index
  end
end
