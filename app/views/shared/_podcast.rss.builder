# This is the general template for podcast feeds. It is being used in
# several contexts:
#
#  * app/views/landing_page/index.rss.builder
#  * app/views/users/show.rss.builder
#  * app/views/venues/show.rss.builder
#
# All channel level data is passed via the `podcast` object.
#
# Some best practices adopted from these well established podcasts:
#
#  * http://feeds.twit.tv/twit.xml
#  * http://feed.nashownotes.com/rss.xml
#
#
# FIXME: itunes category hardcoded - where to get ahold of it?
# FIXME: xml.lang is hardcoded
#
namespaces = {
  'xmlns:atom'            => "http://www.w3.org/2005/Atom",
  'xmlns:media'           => "http://search.yahoo.com/mrss/",
  'xmlns:itunes'          => "http://www.itunes.com/dtds/podcast-1.0.dtd",
  'xmlns:creativeCommons' => "http://backend.userland.com/creativeCommonsRssModule",
  'xmlns:sy'              => "http://purl.org/rss/1.0/modules/syndication/",
  # see http://web.resource.org/rss/1.0/modules/dc/
  'xmlns:dc'              => "http://purl.org/dc/elements/1.1/"
}

xml.instruct!
xml.rss namespaces.merge(version: '2.0') do
  xml.channel do

    xml.title { xml.cdata! @podcast.title }
    xml.dc(:title) { xml.cdata! @podcast.title }
    
    xml.description do
      xml.cdata! @podcast.description
    end
    xml.link @podcast.url
    xml.language 'DE'
    xml.image do
      xml.url @podcast.image_url
      xml.title do
        xml.cdata! @podcast.image_title
      end
      xml.link @podcast.image_link
    end
    #xml.tag! 'atom:link', rel: 'self', 
    #                      type: 'application/rss+xml', 
    #                      href: venue_talks_url(@venue, format: :rss)

    xml.itunes :image, href: @podcast.image_url
    xml.itunes :category, text: @podcast.category
    xml.itunes :subtitle, @podcast.subtitle
    xml.itunes :summary do
      xml.cdata! @podcast.description
    end
    xml.itunes :explicit, 'no'
    #xml.itunes :owner do 
    #  xml.itunes :email, @venue.user.email
    #end
    xml.itunes :author, @podcast.author
    xml.dc :creator, @podcast.author
    
    talks = @podcast.talks || []
    talks.each do |talk|
      xml.item do
        xml.title h talk.title
        xml.description h talk.description
        xml.itunes :subtitle, talk.teaser
        xml.itunes :summary, talk.description
        xml.itunes :author, talk.venue.user.name
        xml.itunes :duration, vrmedia_duration(talk)
        xml.itunes :explicit, 'no'
        xml.itunes :image, href: talk.image.thumb('1400x1400#').url
        xml.pubDate talk.processed_at.to_s(:rfc822)
        xml.link venue_talk_url(talk.venue, talk)
        xml.guid venue_talk_url(talk.venue, talk), isPermaLink: true
        xml.enclosure url: vrmedia_url(talk),
                      type: "audio/mpeg",
                      length: vrmedia_size(talk)
      end
    end
  end
end
