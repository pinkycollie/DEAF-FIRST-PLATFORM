# Supabase Configuration for DEAF-FIRST ASL Biometrics
# Free Tier Deployment

# Database Schema
# ================
# Run these SQL commands in Supabase SQL Editor

# Create biometric profiles table
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Biometric profiles table
CREATE TABLE IF NOT EXISTS biometric_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE,
    enrollment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    dominant_hand VARCHAR(10) NOT NULL CHECK (dominant_hand IN ('left', 'right')),
    preferred_signs TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Signature patterns table (encrypted biometric data)
CREATE TABLE IF NOT EXISTS signature_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES biometric_profiles(id) ON DELETE CASCADE,
    pattern_id UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    sign_type VARCHAR(50) NOT NULL,
    features_encrypted TEXT NOT NULL, -- Encrypted JSON of motion features
    captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES biometric_profiles(id)
);

-- Telehealth sessions table
CREATE TABLE IF NOT EXISTS telehealth_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL UNIQUE,
    patient_id UUID NOT NULL,
    provider_id UUID NOT NULL,
    session_type VARCHAR(20) NOT NULL CHECK (session_type IN ('consultation', 'followup', 'prescription', 'emergency')),
    verification_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'failed', 'expired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    verified_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ
);

-- Verification attempts log (for audit)
CREATE TABLE IF NOT EXISTS verification_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES telehealth_sessions(id),
    attempt_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    result VARCHAR(20) NOT NULL CHECK (result IN ('success', 'failure', 'error')),
    match_score DECIMAL(4,3),
    quality_score DECIMAL(4,3),
    error_message TEXT
);

-- Indexes for performance
CREATE INDEX idx_profiles_user_id ON biometric_profiles(user_id);
CREATE INDEX idx_patterns_profile_id ON signature_patterns(profile_id);
CREATE INDEX idx_sessions_patient_id ON telehealth_sessions(patient_id);
CREATE INDEX idx_sessions_status ON telehealth_sessions(verification_status);
CREATE INDEX idx_attempts_session_id ON verification_attempts(session_id);

-- Row Level Security (RLS)
ALTER TABLE biometric_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE signature_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE telehealth_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_attempts ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only access their own biometric data
CREATE POLICY "Users can view own profile"
    ON biometric_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON biometric_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON biometric_profiles FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile"
    ON biometric_profiles FOR DELETE
    USING (auth.uid() = user_id);

-- Patterns inherit profile policies
CREATE POLICY "Users can view own patterns"
    ON signature_patterns FOR SELECT
    USING (profile_id IN (SELECT id FROM biometric_profiles WHERE user_id = auth.uid()));

CREATE POLICY "Users can insert own patterns"
    ON signature_patterns FOR INSERT
    WITH CHECK (profile_id IN (SELECT id FROM biometric_profiles WHERE user_id = auth.uid()));

-- Sessions accessible by patients and providers
CREATE POLICY "Session access for participants"
    ON telehealth_sessions FOR SELECT
    USING (patient_id = auth.uid() OR provider_id = auth.uid());

-- Function to clean up expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE telehealth_sessions
    SET verification_status = 'expired'
    WHERE verification_status = 'pending'
    AND created_at < NOW() - INTERVAL '1 hour';
    
    -- Delete old ended sessions (keep for audit)
    DELETE FROM telehealth_sessions
    WHERE ended_at < NOW() - INTERVAL '30 days';
END;
$$;

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_biometric_profiles_updated_at
    BEFORE UPDATE ON biometric_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

# Environment Variables
# =====================
# Add these to your Vercel/Railway environment:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Encryption Key for Biometric Data (generate with: openssl rand -base64 32)
BIOMETRIC_ENCRYPTION_KEY=your-encryption-key

# Session Secret
SESSION_SECRET=your-session-secret
```

# Free Tier Limits
# ================
# - Database: 500 MB
# - Auth: 50,000 monthly active users
# - Storage: 1 GB
# - Edge Functions: 500,000 invocations
# - Realtime: 200 concurrent connections

# Best Practices for Free Tier
# ============================
# 1. Use database indexes to reduce query time
# 2. Encrypt biometric data before storing (reduces storage size)
# 3. Clean up expired sessions regularly
# 4. Use Row Level Security for data isolation
# 5. Monitor usage in Supabase dashboard
