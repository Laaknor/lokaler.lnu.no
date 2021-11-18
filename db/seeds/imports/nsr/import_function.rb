# frozen_string_literal: true

# rubocop:disable all

require "json"
require "set"
require "./db/seeds/imports/nsr/helpers"

def import_spaces_from_nsr_schools
  # Counts
  p({
      info: "In db before import from NSR:",
      spaces: Space.count,
      space_types: SpaceType.count,
      space_owners: SpaceOwner.count,
      space_contacts: SpaceContact.count
    })

  # Load json file
  file = File.read(Rails.root.join("db", "seeds", "imports", "nsr", "nsrParsedSchools.json"))
  data = filter_schools(JSON.parse(file))

  p raw_schools_to_parse: data.length

  # Set up and save SpaceTypes
  space_types = [
    { type_name: "barneskole" },
    { type_name: "ungdomsskole" },
    { type_name: "grunnskole" },
    { type_name: "vgs" }
  ]
  p "importing #{space_types.length} space types"
  SpaceType.import new_all_unless_exists(SpaceType, space_types)

  # Trawl through it, and extract information into Rails format

  # Set up owners first:
  space_owners = Set[]
  data.each do |school|
    space_owners << space_owner_from(school)
  end
  # Save them
  p "importing #{space_owners.length} space owners"
  SpaceOwner.import new_all_unless_exists(SpaceOwner, space_owners)

  # Then start parsing Spaces, as they depend on the above
  spaces = []
  space_contacts = []
  p "Parsing spaces and space contacts"
  data.each do |school|
    space = new_unless_exists Space, space_from(school)
    spaces << space if space

    space_contacts_from(school).each do |contact|
      space_contact = new_unless_exists SpaceContact, contact
      if space_contact
        space_contact.space = space || Space.find_by(space_from(school))
        space_contacts << space_contact if space_contact
      end
    end
  end
  # Save them all with import
  p "importing #{spaces.length} spaces"
  Space.import(spaces)

  p "Aggregating facility reviews for spaces (takes a minute)"
  spaces.each do |space|
    Facility.all.order(:created_at).map do |facility|
      AggregatedFacilityReview.create!(experience: "unknown", space: space, facility: facility)
    end
  end

  p "importing #{space_contacts.length} space contacts"
  SpaceContact.import(space_contacts)


  p({
      info: "To import from NSR JSON:",
      spaces: spaces.length,
      space_types: space_types.length,
      space_owners: space_owners.length
    })
  p({
      info: "In db after import from NSR:",
      spaces: Space.count,
      space_types: SpaceType.count,
      space_owners: SpaceOwner.count,
      space_contacts: SpaceContact.count
    })
end

# rubocop:enable all
