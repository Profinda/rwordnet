module WordNet

  SYNSET_TYPES = {"n" => "noun", "v" => "verb", "a" => "adj", "r" => "adv"}

  # Represents a synset (or group of synonymous words) in WordNet. Synsets are related to each other by various (and numerous!)
  # relationships, including Hypernym (x is a hypernym of y <=> x is a parent of y) and Hyponym (x is a child of y)
  class Synset
    attr_reader :gloss, :synset_offset, :lex_filenum, :ss_type, :w_cnt, :wordcounts, :pos_offset, :pos

    # Create a new synset by reading from the data file specified by +pos+, at +offset+ bytes into the file. This is how
    # the WordNet database is organized. You shouldn't be creating Synsets directly; instead, use Lemma#synsets.
    def initialize(pos, offset)
      data = File.open(File.join(DB.path,"dict","data.#{SYNSET_TYPES[pos]}"),"r")
      data.seek(offset)
      data_line = data.readline.strip
      data.close

      info_line, @gloss = data_line.split(" | ")
      line = info_line.split(" ")

      @pos = pos
      @pos_offset = offset
      @synset_offset = line.shift
      @lex_filenum = line.shift
      @ss_type = line.shift
      @w_cnt = line.shift.to_i
      @wordcounts = {}
      @w_cnt.times do
        @wordcounts[line.shift] = line.shift.to_i
      end

      @p_cnt = line.shift.to_i
      @pointers = Array.new(@p_cnt).map do
        Pointer.new(
          symbol: line.shift[0],
          offset: line.shift.to_i,
          pos: line.shift,
          source: line.shift
        )
      end
    end

    # How many words does this Synset include?
    def size
      @wordcounts.size
    end

    # Get a list of words included in this Synset
    def words
      @wordcounts.keys
    end

    # List of valid +pointer_symbol+s is in pointers.rb
    def get_relation(pointer_symbol)
      @pointers.reject { |pointer| pointer.symbol != pointer_symbol }.map { |pointer| Synset.new(@ss_type, pointer.offset) }
    end

    # Get the Synset of this sense's antonym
    def antonym
      get_relation(ANTONYM)
    end

    # Get the parent synset (higher-level category, i.e. fruit -> reproductive_structure).
    def hypernym
      get_relation(HYPERNYM)[0]
    end

    # Get the child synset(s) (i.e., lower-level categories, i.e. fruit -> edible_fruit)
    def hyponym
      get_relation(HYPONYM)
    end

    # Get the entire hypernym tree (from this synset all the way up to +entity+) as an array.
    def expanded_hypernym
      parent = self.hypernym
      list = []
      return list if parent.nil?
      while not parent.nil?
        break if list.include? parent.pos_offset
        list.push parent.pos_offset
        parent = parent.parent
      end

      return list.flatten.map { |offset| Synset.new(@pos, offset)}
    end

    def to_s
      "(#{@ss_type}) #{words.map {|x| x.gsub('_',' ')}.join(', ')} (#{@gloss})"
    end

    alias parent hypernym
    alias children hyponym
  end

end
