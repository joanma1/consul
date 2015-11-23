namespace :proposals do

  desc "Updates all proposals by recalculating their hot_score"
  task touch: :environment do
    Proposal.find_in_batches do |proposals|
      proposals.each(&:save)
    end
  end

  desc "Add spaces to proposal titles and questions that are too short"
  task padding: :environment do
    Proposal.find_in_batches do |proposals|

      proposals.each do |proposal|
        title = proposal.title
        if title.size < 4
          proposal.update_attribute(:title, title.ljust(4))
        end

        question = proposal.question
        if question.size < 10
          proposal.update_attribute(:question, question.ljust(10))
        end
      end

    end
  end

end
