require 'mongo'

module Infrastructure
  class Client_votes
    class << self
      def insert_one(document)
        collection_votes.insert_one(document)
      end

      def flush
        collection_votes.drop
      end

      def find_one(id, user)
        collection_votes.find(id_proposal: id, user: user).first
      end

      def count_decision(id, decision)
        collection_votes.count(id_proposal: id, decision: decision)
      end

      def update(vote, decision)
        vote.decision = decision
        vote_serialized = vote.serialize
        collection_votes.find_one_and_replace({ id_proposal: vote.id_proposal, user: vote.user }, vote_serialized)
      end

      def count_user_votes(id, user)
        collection_votes.count(id_proposal: id, user: user)
      end

      private

      def client_votes
        mongo_uri = ENV['MONGODB_URI']
        Mongo::Logger.logger.level = Logger::INFO

        @client_votes ||= Mongo::Client.new(mongo_uri)
      end

      def collection_votes
         client_votes[:votes]
      end
    end
  end
end
