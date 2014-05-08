class BackfillClassificationPositions < ActiveRecord::Migration
  def up
    Spree::Taxon.all.each do |taxon|
      taxon.classifications.each_with_index do |c, i|
        c.update_attribute(:position, i+1)
      end
    end
  end

  def down
  end
end
