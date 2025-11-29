import os
import sys
import re

def parse_wwise_ids(header_path):
    """
    Parses a Wwise_IDs.h file to create a map from AkUniqueID (event_id) to the 
    corresponding C variable name (the desired final name).

    Expected format: static const AkUniqueID [name] = [event_id]U;
    
    Args:
        header_path (str): The path to the Wwise_IDs.h file.

    Returns:
        dict: A dictionary mapping event_id (int) to name (str).
    """
    id_to_name = {}
    
    # Regex to capture the variable name and the integer ID.
    # Group 1: Name (e.g., AK_EVENT_Music_Main)
    # Group 2: ID (e.g., 123456789)
    # We look for the common AkUniqueID declaration format.
    id_pattern = re.compile(r'static const AkUniqueID (\w+) = (\d+)U;')

    print(f"--- 1. Parsing Wwise Header: {os.path.basename(header_path)} ---")
    try:
        with open(header_path, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                match = id_pattern.search(line)
                if match:
                    name = match.group(1)
                    event_id = int(match.group(2))
                    
                    # Optionally clean up common prefixes like AK_EVENT_
                    if name.startswith("AK_EVENT_"):
                        name = name[9:]
                    
                    id_to_name[event_id] = name
                    # print(f"  Found: ID {event_id} -> Name '{name}'")

    except FileNotFoundError:
        print(f"ERROR: Header file not found at '{header_path}'")
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred while reading the header file: {e}")
        sys.exit(1)
        
    print(f"Successfully mapped {len(id_to_name)} Wwise IDs.")
    return id_to_name

def rename_txtp_files(id_to_name):
    """
    Finds .txtp files in the current directory, extracts the category and ID, 
    and renames them using the provided map.
    
    Expected filename format: [category] ([any_number]=[any_number])(ID=[event_id]).txtp
    """
    print("\n--- 2. Renaming TXTP Files in txtp Directory ---")
    
    # Regex to extract Category and Event ID from TXTP filename.
    # Group 1: Category (e.g., Music)
    # Group 2: Event ID (e.g., 123456789)
    # Note: This is designed to be flexible for the content of the first bracketed group.
    txtp_pattern = re.compile(r'^(\S*)\s+.*\(\d+=(\d+)\)( \{r\})?\.txtp$', re.IGNORECASE)
    
    rename_count = 0
    
    for filename in os.listdir('.'):
        if not filename.lower().endswith('.txtp'):
            continue
            
        match = txtp_pattern.match(filename)
        
        if match:
            # Extract Category (Group 1) and Event ID (Group 2)
            category = match.group(1).strip()
            event_id = int(match.group(2))
            
            # Look up the new name using the ID
            new_name = id_to_name.get(event_id)
            
            if not new_name:
                new_name = event_id
                
            # Construct the new filename
            new_filename = f"{category}-{new_name}.txtp"
            
            try:
                try:
                    os.stat(new_filename)
                    os.unlink(filename)
                    print(f"  Deleted duplicate: '{filename}'")
                except:
                    os.rename(filename, new_filename)
                    print(f"  Renamed: '{filename}' -> '{new_filename}'")
                rename_count += 1
            except Exception as e:
                print(f"  ERROR: Could not rename '{filename}'. Reason: {e}")
        else:
            print(f"  Skipped: '{filename}' (does not match expected TXTP pattern)")

    print(f"\nCompleted. Total files renamed: {rename_count}")


def main():
    header_file_path = '../../Audio/GeneratedSoundBanks/Wwise_IDs.h'
    
    # 1. Parse the header file to get the ID map
    id_map = parse_wwise_ids(header_file_path)
    
    # 2. Rename the TXTP files
    if id_map:
        rename_txtp_files(id_map)
    else:
        print("No IDs were successfully parsed. Aborting rename operation.")


if __name__ == "__main__":
    main()
