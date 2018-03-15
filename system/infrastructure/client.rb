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
        Mongo::Logger.logger.level = Logger::INFO

        @client ||= Mongo::Client.new('mongodb://mongo:27017/db')
      end

      def collection
        client[:proposals]
      end
    end
  end
end
