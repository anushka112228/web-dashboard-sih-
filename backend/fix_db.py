import psycopg2
from app.core.config import settings

def fix_database():
    print("🔧 Connecting to database to wipe bad tables...")
    
    # 1. Connect directly to the database
    try:
        conn = psycopg2.connect(
            dbname=settings.POSTGRES_DB,
            user=settings.POSTGRES_USER,
            password=settings.POSTGRES_PASSWORD,
            host=settings.POSTGRES_HOST,
            port=settings.POSTGRES_PORT
        )
        conn.autocommit = True
        cursor = conn.cursor()
        
        # 2. Drop the 'users' table (and anything related to it)
        print("🗑️  Dropping 'users' table...")
        cursor.execute("DROP TABLE IF EXISTS users CASCADE;")
        
        # 3. Verify it's gone
        cursor.execute("SELECT to_regclass('public.users');")
        if cursor.fetchone()[0] is None:
            print("✅ 'users' table successfully deleted.")
        else:
            print("❌ FAILED to delete 'users' table.")
            
        cursor.close()
        conn.close()
        
        print("\n🚀 NOW: Restart your backend server (uvicorn).")
        print("   It will automatically recreate the table with the correct columns.")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    fix_database()
