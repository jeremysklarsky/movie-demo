        # CriticPublication.find_or_create_by_critic_id_and_publication_id_and_value(:critic_id => critic_review.critic.id, :publication_id => critic_review.publication.id)

desc "Add Critic Publications"
task :critic_publication => :environment do

  CriticReview.all.each do |review|
    critic = Critic.find(review.critic.id)
    publication = Publication.find(review.publication.id)
    critic.publications << publication if !critic.publications.include?(publication)
  end
end