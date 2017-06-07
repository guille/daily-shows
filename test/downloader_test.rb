require "test_helper"

describe DownloadTV::Downloader do
	before do
		Dir.chdir(File.dirname(__FILE__))
		File.delete("date") if File.exist?("date")
	end

	describe "when creating the object" do
		it "should receive an integer" do
			->{ DownloadTV::Downloader.new("foo") }.must_raise NoMethodError
		end

		it "should store the first argument as @offset" do
			DownloadTV::Downloader.new(3).offset.must_equal 3
		end

	end

	describe "the fix_names function" do
		it "should remove apostrophes and parens" do
			shows = ["Mr. Foo S01E02", "Bar (UK) S00E22", "Let's S05E03"]
			result = ["Mr. Foo S01E02", "Bar S00E22", "Lets S05E03"]
			DownloadTV::Downloader.new(0).fix_names(shows).must_equal result
		end

		it "should remove ignored shows" do
			DownloadTV::CONFIG[:ignored] = ["Ignored"]
			shows = ["Mr. Foo S01E02", "Bar (UK) S00E22", "Ignored S20E22", "Let's S05E03"]
			result = ["Mr. Foo S01E02", "Bar S00E22", "Lets S05E03"]
			DownloadTV::Downloader.new(0).fix_names(shows).must_equal result
		end
	end


	describe "the date file" do 
		dl = DownloadTV::Downloader.new(0)



		it "should be created if it doesn't exist" do
			dl.check_date
			File.exist?("date").must_equal true
		end

		it "contains a date after running the method" do
			date = dl.check_date
			date.must_equal (Date.today-1)
			Date.parse(File.read("date")).must_equal Date.today-1
		end

		it "exits the script when up to date" do
			File.write("date", Date.today)
			begin
				dl.check_date
				flunk
			rescue SystemExit
			
			end
		end
		
	end

end