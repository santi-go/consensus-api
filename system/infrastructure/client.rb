require 'mongo'

module Infrastructure
  class Client
    class << self
      def insert_one(document)
        collection.insert_one(document)
      end

      def find_one(id)
        collection.find(id_proposal: id).first
      end

      def flush
        collection.drop
      end

      private

      def client
        mongo_uri = ENV['MONGODB_URI']
        Mongo::Logger.logger.level = Logger::INFO

        @client ||= Mongo::Client.new(mongo_uri)
      end

      def collection
        client[:proposals]
      end
    end
  end
end
