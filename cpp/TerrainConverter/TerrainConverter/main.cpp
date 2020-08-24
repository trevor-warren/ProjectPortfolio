#include <filesystem>
#include <iostream>
#include <fstream>
#include <sstream>

typedef std::filesystem::path FilePath;

struct Cell
{
	bool full = false;
	unsigned char material = 0;
	unsigned char fraction = 0;

	bool operator==(const Cell& other) const
	{
		return full == other.full && material == other.material && fraction == other.fraction;
	}
};

struct Chunk
{
	int x = 0;
	int y = 0;
	int z = 0;

	Cell cells[16][16][16];
};

unsigned short expand(char input, unsigned char mask, unsigned short shifts)
{
	return ((unsigned char(input) - 32) & mask) << shifts;
}

void parseChunk(std::ifstream& inputFile, Chunk& output)
{
	char buffer[5] = {};

	inputFile >> output.x;
	inputFile.read(buffer, 1);

	inputFile >> output.y;
	inputFile.read(buffer, 1);
	
	inputFile >> output.z;
	inputFile.getline(buffer, 5);

	for (int x = 0; x < 16; ++x)
	{
		for (int y = 0; y < 16; ++y)
		{
			for (int z = 0; z < 16; ++z)
			{
				char material;
				char occupancy[2];

				inputFile.read(&material, 1);
				inputFile.read(occupancy, 2);

				Cell& cell = output.cells[x][y][z];

				cell.material = unsigned char(material) - 32;
				cell.fraction = expand(occupancy[0], 0x03, 6) | expand(occupancy[1], 0x3F, 0);
				cell.full = (occupancy[0] & 0x04) != 0;
			}

			inputFile.getline(buffer, 5);
		}
	}
}

void copy(char* buffer, int& start, const char* source, int amount)
{
	for (int i = 0; i < amount && start < 3 * 16; ++i)
	{
		buffer[start] = source[i];

		++start;
	}
}

bool buffersMatch(const char* buffer1, int size1, const char* buffer2, int size2)
{
	if (size1 != size2)
		return false;

	for (int i = 0; i < size1; ++i)
		if (buffer1[i] != buffer2[i])
			return false;

	return true;
}

void dumpBench(std::ofstream& output, const char* bench, int& benchSize, int& emptyRows, int& repeatedRows)
{
	char repetitonFlag = (emptyRows << 4) | repeatedRows;

	output.write(&repetitonFlag, 1);
	output.write(bench, benchSize);

	benchSize = 0;
	emptyRows = 0;
	repeatedRows = 0;
}

void dumpInt(std::ofstream& output, int value)
{
	char data[4] = { char((value & 0xFF000000) >> 24), char((value & 0xFF0000) >> 16), char((value & 0xFF00) >> 8), char(value & 0xFF) };

	output.write(data, 4);
}

void dumpChunk(const Chunk& chunk, const FilePath& outputDirectory)
{
	std::stringstream fileName;

	fileName << "c_" << chunk.x << "_" << chunk.y << "_" << chunk.z << ".cnk";

	std::ofstream output(outputDirectory / FilePath(fileName.str()), std::ios_base::binary);

	//dumpInt(output, chunk.x);
	//dumpInt(output, chunk.y);
	//dumpInt(output, chunk.z);

	for (int x = 0; x < 16; ++x)
	{
		char rowBench[3 * 16] = { 0 };
		int benchSize = 0;
		int emptyRows = 0;
		int repeatedRows = 0;

		for (int y = 0; y < 16; ++y)
		{
			char rowBuffer[3 * 16] = { 0 };
			int rowSize = 0;
			bool emptyRow = false;

			for (int z = 0; z < 16; ++z)
			{
				char buffer[3] = { char(0xFF) };
				int empty = 0;

				for (empty; empty < 16 && z + empty < 16 && chunk.cells[x][y][z + empty].material == 0; ++empty);

				z += empty;

				if (z >= 16)
				{
					copy(rowBuffer, rowSize, buffer, 1);

					if (empty == 16)
						emptyRow = true;
				}
				else
				{
					const Cell& cell = chunk.cells[x][y][z];

					buffer[0] = empty << 4;
					buffer[1] = char(cell.material | (cell.full << 7));

					if (!cell.full)
						buffer[2] = char(cell.fraction);

					int repeated = 0;

					for (repeated; repeated < 16 - empty && z + repeated < 16 && chunk.cells[x][y][z + repeated] == cell; ++repeated);

					buffer[0] |= repeated - 1;

					copy(rowBuffer, rowSize, buffer, cell.full ? 2 : 3);

					z += repeated - 1;
				}
			}

			if (emptyRow)
			{
				if (benchSize == 0)
					++emptyRows;
				else
				{
					dumpBench(output, rowBench, benchSize, emptyRows, repeatedRows);

					++emptyRows;
				}
			}
			else
			{
				if (buffersMatch(rowBench, benchSize, rowBuffer, rowSize))
					++repeatedRows;
				else
				{
					if (benchSize != 0)
						dumpBench(output, rowBench, benchSize, emptyRows, repeatedRows);

					copy(rowBench, benchSize, rowBuffer, rowSize);
				}
			}
		}

		if (benchSize != 0)
			dumpBench(output, rowBench, benchSize, emptyRows, repeatedRows);
		else if (emptyRows > 0)
		{
			char endOfLayer = char(0xFF);

			output.write(&endOfLayer, 1);
		}
	}
}

void processChunks(const FilePath& inputDirectory, const FilePath& outputDirectory)
{
	std::ifstream inputFile(inputDirectory, std::ios::in);

	char cdataTag[] = { '[', 'C', 'D', 'A', 'T', 'A', '[', 0 };

	for (int i = 0; i < 8; ++i)
		cdataTag[i] = 0;

	while (!inputFile.eof())
	{
		inputFile.read(cdataTag, 1);

		int count = inputFile.gcount();

		bool bad = inputFile.bad();
		bool fail = inputFile.fail();

		if (count == 1 && cdataTag[0] == '[')
		{
			inputFile.read(cdataTag + 1, 6);

			if (!inputFile.eof() && inputFile.gcount() == 6 && cdataTag == std::string("[CDATA["))
			{
				Chunk chunk;

				parseChunk(inputFile, chunk);
				dumpChunk(chunk, outputDirectory);
			}

			for (int i = 0; i < 8; ++i)
				cdataTag[i] = 0;
		}
	}
}

void clearOutput(const FilePath& outputDirectory)
{
	std::filesystem::remove_all(outputDirectory);
	std::filesystem::create_directory(outputDirectory);
}

int main(int argc, char** argv)
{
	if (argc != 3)
	{
		std::cout << "error: expected 3 arguments" << std::endl;
		std::cout << argv[0] << " <input>.rbxmx <output_directory>" << std::endl;

		return -1;
	}
	
	FilePath inputDirectory(argv[1]);
	
	if (!std::filesystem::exists(inputDirectory))
	{
		std::cout << "input path doesn't exist" << std::endl;

		return -1;
	}
	
	if (!std::filesystem::is_regular_file(inputDirectory))
	{
		std::cout << "input path doesn't point to a file" << std::endl;

		return -1;
	}
	
	if (inputDirectory.extension() != ".rbxmx")
	{
		std::cout << "input file isn't a .rbxmx" << std::endl;

		return -1;
	}

	FilePath outputDirectory(argv[2]);
	bool outputDirectoryExists = std::filesystem::exists(outputDirectory);

	if (outputDirectoryExists)
	{
		if (!std::filesystem::is_directory(outputDirectory))
		{
			std::cout << "output path isn't a directory" << std::endl;

			return -1;
		}

		std::cout << "clear output directory? ";

		std::string answer;

		std::cin >> answer;

		if (answer == "yes" || answer == "y")
			clearOutput(outputDirectory);
	}
	else
		std::filesystem::create_directories(outputDirectory);

	processChunks(inputDirectory, outputDirectory);
	
	return 0;
}