-- Sample Announcements for Testing
-- Insert sample data into announcements table

-- Sample announcement from admin
INSERT INTO announcements (title, body, posted_by, target_role_id, published_at, expires_at, is_deleted)
VALUES
('Welcome to School Year 2025-2026',
'Welcome back to all students, teachers, and staff! We are excited to begin another great school year. Classes will officially start on June 5, 2025. Please make sure to complete your enrollment requirements.',
1,
NULL,
'2025-06-01 08:00:00',
NULL,
0),

('Enrollment Schedule Extended',
'The enrollment period has been extended until June 15, 2025. Please visit the Registrar''s Office during office hours (8:00 AM - 5:00 PM) to complete your enrollment. Don''t forget to bring the necessary documents.',
1,
NULL,
'2025-06-03 10:30:00',
'2025-06-15 17:00:00',
0),

('Parent-Teacher Conference',
'We will be holding a Parent-Teacher Conference on July 20, 2025, from 2:00 PM to 5:00 PM. This is a great opportunity to discuss your child''s progress and address any concerns. We look forward to seeing you there!',
1,
NULL,
'2025-07-10 14:00:00',
'2025-07-20 17:00:00',
0),

('First Quarter Grading Period',
'The first quarter grading period will end on August 30, 2025. Report cards will be available for viewing on September 5, 2025. Teachers, please ensure all grades are submitted by September 2, 2025.',
1,
2,
'2025-08-15 09:00:00',
'2025-08-30 23:59:59',
0),

('COVID-19 Safety Protocols',
'In line with DepEd guidelines, we will continue to implement health and safety protocols. All students and staff are required to wear face masks in crowded areas. Hand sanitizing stations are available throughout the campus.',
1,
NULL,
'2025-06-01 07:00:00',
NULL,
0);

-- Note: Adjust posted_by to match an actual user_id in your users table
-- Note: Adjust target_role_id to match actual role_id in your roles table (NULL = all users)
