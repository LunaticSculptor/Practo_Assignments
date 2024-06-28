-- Drop tables if they already exist to start fresh
DROP TABLE IF EXISTS Appointment, Clinic, Doctor, "User";

-- Create the tables
CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    birthdate DATE
);

CREATE TABLE Doctor (
    doctor_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    specialty VARCHAR(100)
);

CREATE TABLE Clinic (
    clinic_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE Appointment (
    appointment_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id),
    doctor_id INT REFERENCES Doctor(doctor_id),
    clinic_id INT REFERENCES Clinic(clinic_id),
    appointment_time TIMESTAMP,
    status VARCHAR(20)
);

-- Create indexes
CREATE INDEX idx_user_birthdate ON "User"(birthdate);
CREATE INDEX idx_appointment_doctor_id ON Appointment(doctor_id);
CREATE INDEX idx_appointment_user_id ON Appointment(user_id);
CREATE INDEX idx_appointment_clinic_id ON Appointment(clinic_id);
CREATE INDEX idx_appointment_time ON Appointment(appointment_time);
CREATE INDEX idx_appointment_status ON Appointment(status);

-- Insert fixed data into "User" table
DO $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= 1000 LOOP
        INSERT INTO "User" (name, birthdate)
        VALUES
            ('User ' || i, 
             '1980-01-01'::DATE + (i % 365) * INTERVAL '1 day'
            );
        i := i + 1;
    END LOOP;
END $$;

-- Insert fixed data into "Doctor" table
DO $$
DECLARE
    specialties TEXT[] := ARRAY['Cardiology', 'Pediatrics', 'Dermatology', 'Orthopedics', 'Neurology'];
    i INT := 1;
    specialty_index INT;
BEGIN
    WHILE i <= 100 LOOP
        specialty_index := ((i - 1) % array_length(specialties, 1)) + 1;
        INSERT INTO Doctor (name, specialty)
        VALUES
            ('Dr. ' || CHR(65 + ((i - 1) % 26)) || CHR(97 + ((i - 1) % 26)),
             specialties[specialty_index]
            );
        i := i + 1;
    END LOOP;
END $$;

-- Insert fixed data into "Clinic" table
DO $$
DECLARE
    locations TEXT[] := ARRAY['New York', 'Los Angeles', 'Chicago', 'San Francisco', 'Houston'];
    i INT := 1;
    location_index INT;
BEGIN
    WHILE i <= 50 LOOP
        location_index := ((i - 1) % array_length(locations, 1)) + 1;
        INSERT INTO Clinic (name, location)
        VALUES
            ('Clinic ' || i,
             locations[location_index]
            );
        i := i + 1;
    END LOOP;
END $$;

-- Insert fixed data into "Appointment" table
DO $$
DECLARE
    i INT := 1;
    j INT;
    appointment_time TIMESTAMP;
BEGIN
    WHILE i <= 1000 LOOP
        j := 1;
        WHILE j <= 10 LOOP
            appointment_time := NOW() - (i % 10) * INTERVAL '1 day' + (j % 24) * INTERVAL '1 hour';
            INSERT INTO Appointment (user_id, doctor_id, clinic_id, appointment_time, status)
            VALUES
                (i,                       -- user_id
                 (j % 100) + 1,           -- doctor_id
                 (j % 50) + 1,            -- clinic_id
                 appointment_time,
                 CASE WHEN j % 5 = 0 THEN 'cancelled' ELSE 'scheduled' END
                );
            j := j + 1;
        END LOOP;
        i := i + 1;
    END LOOP;
END $$;

-- 1. All appointments booked in last 7 days for a doctor
-- Query to fetch all appointments booked in the last 7 days for a specific doctor (doctor_id = 1)
SELECT * FROM Appointment
WHERE doctor_id = 1 AND appointment_time >= NOW() - INTERVAL '7 days';

-- 2. All appointments booked in last 2 days and scheduled within next 5 hours for a doctor
-- Query to fetch all appointments booked in the last 2 days and scheduled within the next 5 hours for a specific doctor (doctor_id = 1)
SELECT * FROM Appointment
WHERE doctor_id = 1 
AND appointment_time >= NOW() - INTERVAL '2 days' 
AND appointment_time <= NOW() + INTERVAL '5 hours';

-- 3. Users who have at least 1 appointment and have their birthday coming in next 5 days
-- Query to fetch users who have at least one appointment and have their birthday in the next 5 days
SELECT DISTINCT u.* FROM "User" u
JOIN Appointment a ON u.user_id = a.user_id
WHERE EXTRACT(DOY FROM u.birthdate) BETWEEN EXTRACT(DOY FROM NOW()) AND EXTRACT(DOY FROM NOW() + INTERVAL '5 days');

-- 4. Appointments for a particular patient in the last 7 days
-- Query to fetch appointments for a particular patient (user_id = 1) in the last 7 days
SELECT * FROM Appointment
WHERE user_id = 1 AND appointment_time >= NOW() - INTERVAL '7 days';

-- 5. Appointment cancellation percentage for a doctor by clinic
-- Query to fetch the appointment cancellation percentage for a specific doctor (doctor_id = 1) by clinic
SELECT clinic_id,
       COUNT(*) FILTER (WHERE status = 'cancelled')::float / COUNT(*) * 100 AS cancellation_percentage
FROM Appointment
WHERE doctor_id = 1
GROUP BY clinic_id;
