-- Missing Pet / Stray Animal Registry
-- Target: MySQL 8.x / MariaDB 10.4+ (InnoDB, utf8mb4)

CREATE DATABASE IF NOT EXISTS pet_registry_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pet_registry_db;

-- roles
CREATE TABLE roles (
  role_id INT NOT NULL AUTO_INCREMENT,
  role_name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(150),
  PRIMARY KEY (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- users
CREATE TABLE users (
  user_id INT NOT NULL AUTO_INCREMENT,
  role_id INT NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  status ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_users_role_id FOREIGN KEY (role_id) REFERENCES roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- audit_logs
CREATE TABLE audit_logs (
  log_id BIGINT NOT NULL AUTO_INCREMENT,
  user_id INT,
  action VARCHAR(50) NOT NULL,
  table_name VARCHAR(64),
  record_id INT,
  details TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id),
  CONSTRAINT fk_audit_logs_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- species
CREATE TABLE species (
  species_id INT NOT NULL AUTO_INCREMENT,
  species_name VARCHAR(60) NOT NULL UNIQUE,
  PRIMARY KEY (species_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- breeds
CREATE TABLE breeds (
  breed_id INT NOT NULL AUTO_INCREMENT,
  species_id INT NOT NULL,
  breed_name VARCHAR(80) NOT NULL,
  size_class ENUM('Small','Medium','Large'),
  PRIMARY KEY (breed_id),
  UNIQUE KEY uq_breeds_species_id_breed_name (species_id, breed_name),
  CONSTRAINT fk_breeds_species_id FOREIGN KEY (species_id) REFERENCES species(species_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- mark_types
CREATE TABLE mark_types (
  mark_type_id INT NOT NULL AUTO_INCREMENT,
  type_name VARCHAR(60) NOT NULL UNIQUE,
  PRIMARY KEY (mark_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- reporters
CREATE TABLE reporters (
  reporter_id INT NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  reporter_type ENUM('Owner','Finder','Witness','Barangay Official') NOT NULL DEFAULT 'Finder',
  contact_no VARCHAR(20),
  email VARCHAR(100),
  address_line VARCHAR(150),
  barangay VARCHAR(80),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (reporter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- shelters
CREATE TABLE shelters (
  shelter_id INT NOT NULL AUTO_INCREMENT,
  shelter_name VARCHAR(120) NOT NULL,
  shelter_type ENUM('Government','Private','Rescue Group') NOT NULL DEFAULT 'Government',
  address_line VARCHAR(150),
  contact_no VARCHAR(20),
  capacity SMALLINT,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (shelter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- volunteers
CREATE TABLE volunteers (
  volunteer_id INT NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  contact_no VARCHAR(20),
  email VARCHAR(100),
  skills VARCHAR(150),
  availability VARCHAR(100),
  status ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
  date_joined DATE,
  PRIMARY KEY (volunteer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- adopters
CREATE TABLE adopters (
  adopter_id INT NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  contact_no VARCHAR(20),
  email VARCHAR(100),
  address_line VARCHAR(150),
  occupation VARCHAR(80),
  has_other_pets TINYINT(1) NOT NULL DEFAULT 0,
  is_screened TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (adopter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- animal_reports
CREATE TABLE animal_reports (
  report_id INT NOT NULL AUTO_INCREMENT,
  report_no VARCHAR(30) NOT NULL UNIQUE,
  report_type ENUM('Missing','Stray','Found','Injured') NOT NULL,
  reporter_id INT NOT NULL,
  species_id INT NOT NULL,
  breed_id INT,
  animal_name VARCHAR(80),
  sex ENUM('Male','Female','Unknown') NOT NULL DEFAULT 'Unknown',
  age_estimate VARCHAR(40),
  color VARCHAR(80),
  size ENUM('Small','Medium','Large'),
  description TEXT,
  last_seen_location VARCHAR(200),
  last_seen_date DATETIME,
  status ENUM('Open','Sighted','Rescued','In Shelter','Reunited','Adopted','Closed') NOT NULL DEFAULT 'Open',
  recorded_by INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (report_id),
  CONSTRAINT fk_animal_reports_reporter_id FOREIGN KEY (reporter_id) REFERENCES reporters(reporter_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_animal_reports_species_id FOREIGN KEY (species_id) REFERENCES species(species_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_animal_reports_breed_id FOREIGN KEY (breed_id) REFERENCES breeds(breed_id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_animal_reports_recorded_by FOREIGN KEY (recorded_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- animal_images
CREATE TABLE animal_images (
  image_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  image_path VARCHAR(255) NOT NULL,
  caption VARCHAR(200),
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  uploaded_by INT NOT NULL,
  uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (image_id),
  CONSTRAINT fk_animal_images_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_animal_images_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- identifying_marks
CREATE TABLE identifying_marks (
  mark_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  mark_type_id INT NOT NULL,
  description VARCHAR(200) NOT NULL,
  body_location VARCHAR(80),
  PRIMARY KEY (mark_id),
  CONSTRAINT fk_identifying_marks_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_identifying_marks_mark_type_id FOREIGN KEY (mark_type_id) REFERENCES mark_types(mark_type_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- sightings
CREATE TABLE sightings (
  sighting_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  reporter_id INT,
  sighting_date DATETIME NOT NULL,
  location VARCHAR(200) NOT NULL,
  latitude DECIMAL(9,6),
  longitude DECIMAL(9,6),
  condition_notes VARCHAR(255),
  is_verified TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (sighting_id),
  CONSTRAINT fk_sightings_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_sightings_reporter_id FOREIGN KEY (reporter_id) REFERENCES reporters(reporter_id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- report_status_logs
CREATE TABLE report_status_logs (
  log_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  old_status ENUM('Open','Sighted','Rescued','In Shelter','Reunited','Adopted','Closed'),
  new_status ENUM('Open','Sighted','Rescued','In Shelter','Reunited','Adopted','Closed') NOT NULL,
  changed_by INT NOT NULL,
  remarks VARCHAR(255),
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id),
  CONSTRAINT fk_report_status_logs_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_report_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- rescue_actions
CREATE TABLE rescue_actions (
  action_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  action_type ENUM('Capture','Transport','Medical Rescue','Release','Reunion','Surrender to Shelter') NOT NULL,
  action_date DATETIME NOT NULL,
  location VARCHAR(200),
  outcome ENUM('Successful','Unsuccessful','Pending') NOT NULL DEFAULT 'Pending',
  notes TEXT,
  handled_by INT NOT NULL,
  PRIMARY KEY (action_id),
  CONSTRAINT fk_rescue_actions_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_rescue_actions_handled_by FOREIGN KEY (handled_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- rescue_volunteers
CREATE TABLE rescue_volunteers (
  action_id INT NOT NULL,
  volunteer_id INT NOT NULL,
  role_in_action VARCHAR(80),
  PRIMARY KEY (action_id, volunteer_id),
  CONSTRAINT fk_rescue_volunteers_action_id FOREIGN KEY (action_id) REFERENCES rescue_actions(action_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_rescue_volunteers_volunteer_id FOREIGN KEY (volunteer_id) REFERENCES volunteers(volunteer_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- shelter_stays
CREATE TABLE shelter_stays (
  stay_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  shelter_id INT NOT NULL,
  date_in DATE NOT NULL,
  date_out DATE,
  kennel_no VARCHAR(20),
  stay_status ENUM('Current','Transferred','Released','Adopted','Deceased') NOT NULL DEFAULT 'Current',
  PRIMARY KEY (stay_id),
  CONSTRAINT fk_shelter_stays_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_shelter_stays_shelter_id FOREIGN KEY (shelter_id) REFERENCES shelters(shelter_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- medical_notes
CREATE TABLE medical_notes (
  note_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  note_date DATE NOT NULL,
  condition_status ENUM('Healthy','Injured','Sick','Critical') NOT NULL,
  diagnosis VARCHAR(200),
  treatment TEXT,
  weight_kg DECIMAL(5,2),
  is_vaccinated TINYINT(1) NOT NULL DEFAULT 0,
  is_neutered TINYINT(1),
  vet_name VARCHAR(100),
  recorded_by INT NOT NULL,
  PRIMARY KEY (note_id),
  CONSTRAINT fk_medical_notes_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_medical_notes_recorded_by FOREIGN KEY (recorded_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- adoption_records
CREATE TABLE adoption_records (
  adoption_id INT NOT NULL AUTO_INCREMENT,
  report_id INT NOT NULL,
  adopter_id INT NOT NULL,
  adoption_date DATE NOT NULL,
  status ENUM('Pending','Approved','Completed','Returned','Rejected') NOT NULL DEFAULT 'Pending',
  contract_signed TINYINT(1) NOT NULL DEFAULT 0,
  follow_up_date DATE,
  remarks VARCHAR(255),
  processed_by INT NOT NULL,
  PRIMARY KEY (adoption_id),
  CONSTRAINT fk_adoption_records_report_id FOREIGN KEY (report_id) REFERENCES animal_reports(report_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adoption_records_adopter_id FOREIGN KEY (adopter_id) REFERENCES adopters(adopter_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adoption_records_processed_by FOREIGN KEY (processed_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Sample lookup data
-- ------------------------------------------------------------
INSERT INTO roles (role_name, description) VALUES
 ('Administrator','Full system access'),
 ('Animal Control Officer','Handles reports, rescues and adoptions'),
 ('Shelter Staff','Manages shelter stays and medical notes'),
 ('Encoder','Encodes reports and uploads photos');

INSERT INTO species (species_name) VALUES ('Dog'),('Cat'),('Bird'),('Rabbit'),('Other');

INSERT INTO mark_types (type_name) VALUES
 ('Collar'),('ID Tag'),('Microchip'),('Tattoo'),('Scar'),('Coat Pattern'),('Ear Notch'),('Missing Limb'),('Other');
