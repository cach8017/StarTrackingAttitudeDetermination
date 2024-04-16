# 2. Create the Skybox

# Project the Stars: Convert the celestial coordinates (right ascension and declination) from the star catalog into 3D coordinates on the cube. 
# This involves spherical to Cartesian conversion, accounting for the fact that the celestial sphere is projected onto the cube faces.

# Convert the Celestial Coordinates to 3D
# Convert the celestial coordinates of the stars into 3D coordinates on the cube.
# chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/http://faraday.uwyo.edu/~admyers/ASTR5160/handouts/51605.pdf slide 2
# chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.diva-portal.org/smash/get/diva2:1044866/FULLTEXT01.pdf pg 40
# The celestial sphere is projected onto the faces of the cube: need to convert the right ascension and declination of each star into Cartesian coordinates.
# The following formulas (see link above) can be used to convert spherical coordinates to Cartesian coordinates:
# x = cos(declination) * cos(right ascension)
# y = cos(declination) * sin(right ascension)
# z = sin(declination)
# where x, y, and z are the 3D coordinates of the star.
import csv

# Define the path to the CSV file
csv_file = '/Users/carloschavez/Documents/Academic & Professional Development/Academia /MS Aerospace CU Boulder/ASEN 6044 Advance State Estimation/skybox/bright_stars.csv'

# Create empty lists to store the right ascension and declination data
right_ascension = []
declination = []

# Read the CSV file and extract the data
with open(csv_file, 'r') as file:
    reader = csv.reader(file)
    next(reader)  # Skip the header row if it exists
    for row in reader: # Each row contains this: star_id, ra, dec, mag, color, etc
        # star_id = row[0]
        ra = float(row[0]) # start at 0 because the first element in the row is the right ascension and star_id is not read
        dec = float(row[1])
        right_ascension.append(ra)
        declination.append(dec)

# Display the first few entries in the lists
print(right_ascension[:5])
print(declination[:5])

import math
xyz_coordinates = []
# i = 0 # use this to break the loop after the ith iteration and check the first 3D coordinates 
for ra, dec in zip(right_ascension[:], declination[:]):
    # if i == 4:
        x = math.cos(math.radians(dec)) * math.cos(math.radians(ra))
        y = math.cos(math.radians(dec)) * math.sin(math.radians(ra))
        z = math.sin(math.radians(dec))
        xyz_coordinates.append((x, y, z))
        print(f'RA: {ra}, Dec: {dec} -> x: {x:.3f}, y: {y:.3f}, z: {z:.3f}')
        break 
    # i += 1
# Display the first few entries in the list of 3D coordinates
print("\n")
print(xyz_coordinates[:])

# Generate Images: Use these 3D coordinates to plot stars on the interior faces of the cube. Brightness and color data can be taken from the catalog to make the representation realistic.


# 3. Implement the Pinhole Camera Model
# The pinhole camera model is a simple imaging model that simulates the operation of a real camera without lenses.
# Camera Setup: Define the camera's position (likely at the center of the cube), its direction, and the field of view.
# Ray Casting: For each pixel in your simulated camera's image plane, cast a ray from the camera through the pixel and into the skybox.
# Intersection Check: Determine where this ray intersects the cube. The point of intersection tells you which part of the sky (and therefore, which stars) are visible through this pixel.

# 4. Render the Skybox