module Infrastructure
  class Client
    class << self
      @repository_data ||= []

      def insert_one(document)
        @repository_data << document
      end

      def find_one(id)
        result = []
        @repository_data.each do |document|
          if document[:id_proposal] == id
            result = document
          end
        end
        return result
      end

      def flush
        @repository_data = []
      end
    end
  end
end
