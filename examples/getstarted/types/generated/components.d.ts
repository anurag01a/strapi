import type { Schema, Struct } from '@strapi/strapi';

export interface BasicRelation extends Struct.ComponentSchema {
  collectionName: 'components_basic_relations';
  info: {
    displayName: 'Relation';
  };
  attributes: {
    categories: Schema.Attribute.Relation<'oneToMany', 'api::category.category'>;
  };
}

export interface BasicSimple extends Struct.ComponentSchema {
  collectionName: 'components_basic_simples';
  info: {
    description: '';
    displayName: 'simple';
    icon: 'ambulance';
  };
  attributes: {
    name: Schema.Attribute.String & Schema.Attribute.Required;
    test: Schema.Attribute.String;
  };
}

export interface BasicTeamMembers extends Struct.ComponentSchema {
  collectionName: 'components_basic_team_members';
  info: {
    displayName: 'teamMembers';
    icon: 'emotionHappy';
  };
  attributes: {
    bio: Schema.Attribute.Blocks;
    name: Schema.Attribute.String;
    organization: Schema.Attribute.Component<'default.org', true>;
    photo: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    role: Schema.Attribute.String;
  };
}

export interface BlogTestComo extends Struct.ComponentSchema {
  collectionName: 'components_blog_test_comos';
  info: {
    description: '';
    displayName: 'test comp';
    icon: 'air-freshener';
  };
  attributes: {
    name: Schema.Attribute.String & Schema.Attribute.DefaultTo<'toto'>;
  };
}

export interface DefaultApple extends Struct.ComponentSchema {
  collectionName: 'components_default_apples';
  info: {
    description: '';
    displayName: 'apple';
    icon: 'apple-alt';
  };
  attributes: {
    name: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface DefaultCar extends Struct.ComponentSchema {
  collectionName: 'components_default_cars';
  info: {
    displayName: 'car';
    icon: 'align-right';
  };
  attributes: {
    name: Schema.Attribute.String;
  };
}

export interface DefaultClosingperiod extends Struct.ComponentSchema {
  collectionName: 'components_closingperiods';
  info: {
    description: '';
    displayName: 'closingperiod';
    icon: 'angry';
  };
  attributes: {
    dish: Schema.Attribute.Component<'default.dish', true> &
      Schema.Attribute.Required &
      Schema.Attribute.SetMinMax<
        {
          min: 2;
        },
        number
      >;
    end_date: Schema.Attribute.Date & Schema.Attribute.Required;
    label: Schema.Attribute.String & Schema.Attribute.DefaultTo<'toto'>;
    media: Schema.Attribute.Media;
    start_date: Schema.Attribute.Date & Schema.Attribute.Required;
  };
}

export interface DefaultDish extends Struct.ComponentSchema {
  collectionName: 'components_dishes';
  info: {
    description: '';
    displayName: 'dish';
    icon: 'address-book';
  };
  attributes: {
    categories: Schema.Attribute.Relation<'oneToOne', 'api::category.category'>;
    description: Schema.Attribute.Text;
    name: Schema.Attribute.String & Schema.Attribute.DefaultTo<'My super dish'>;
    picture: Schema.Attribute.Media;
    price: Schema.Attribute.Float;
    very_long_description: Schema.Attribute.RichText;
  };
}

export interface DefaultLinks extends Struct.ComponentSchema {
  collectionName: 'components_default_links';
  info: {
    displayName: 'links';
    icon: 'link';
  };
  attributes: {
    platform: Schema.Attribute.String;
    url: Schema.Attribute.String;
  };
}

export interface DefaultOpeningtimes extends Struct.ComponentSchema {
  collectionName: 'components_openingtimes';
  info: {
    description: '';
    displayName: 'openingtimes';
    icon: 'calendar';
  };
  attributes: {
    dishrep: Schema.Attribute.Component<'default.dish', true>;
    label: Schema.Attribute.String &
      Schema.Attribute.Required &
      Schema.Attribute.DefaultTo<'something'>;
    time: Schema.Attribute.String;
  };
}

export interface DefaultOrg extends Struct.ComponentSchema {
  collectionName: 'components_default_orgs';
  info: {
    displayName: 'org';
    icon: 'book';
  };
  attributes: {
    address: Schema.Attribute.String;
    coverOrgImage: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios', true>;
    name: Schema.Attribute.String;
    testComponent: Schema.Attribute.Component<'default.test-component', true>;
  };
}

export interface DefaultOrganization extends Struct.ComponentSchema {
  collectionName: 'components_default_organizations';
  info: {
    displayName: 'organization';
  };
  attributes: {
    address: Schema.Attribute.String;
    coverPhotoOrganization: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios', true>;
    name: Schema.Attribute.String;
  };
}

export interface DefaultRestaurantservice extends Struct.ComponentSchema {
  collectionName: 'components_restaurantservices';
  info: {
    description: '';
    displayName: 'restaurantservice';
    icon: 'cannabis';
  };
  attributes: {
    is_available: Schema.Attribute.Boolean &
      Schema.Attribute.Required &
      Schema.Attribute.DefaultTo<true>;
    media: Schema.Attribute.Media;
    name: Schema.Attribute.String &
      Schema.Attribute.Required &
      Schema.Attribute.DefaultTo<'something'>;
  };
}

export interface DefaultSocialLinks extends Struct.ComponentSchema {
  collectionName: 'components_default_social_links';
  info: {
    displayName: 'socialLinks';
    icon: 'link';
  };
  attributes: {};
}

export interface DefaultTemp extends Struct.ComponentSchema {
  collectionName: 'components_default_temps';
  info: {
    description: '';
    displayName: 'temp';
    icon: 'adjust';
  };
  attributes: {
    name: Schema.Attribute.String & Schema.Attribute.Required;
    url: Schema.Attribute.String;
  };
}

export interface DefaultTestComponent extends Struct.ComponentSchema {
  collectionName: 'components_default_test_components';
  info: {
    displayName: 'testComponent';
    icon: 'archive';
  };
  attributes: {
    testAnotherText: Schema.Attribute.String;
    TestMedia: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios', true>;
    testName: Schema.Attribute.String;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'basic.relation': BasicRelation;
      'basic.simple': BasicSimple;
      'basic.team-members': BasicTeamMembers;
      'blog.test-como': BlogTestComo;
      'default.apple': DefaultApple;
      'default.car': DefaultCar;
      'default.closingperiod': DefaultClosingperiod;
      'default.dish': DefaultDish;
      'default.links': DefaultLinks;
      'default.openingtimes': DefaultOpeningtimes;
      'default.org': DefaultOrg;
      'default.organization': DefaultOrganization;
      'default.restaurantservice': DefaultRestaurantservice;
      'default.social-links': DefaultSocialLinks;
      'default.temp': DefaultTemp;
      'default.test-component': DefaultTestComponent;
    }
  }
}
