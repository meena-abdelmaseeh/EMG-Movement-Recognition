function Folders = ExcludeFilesFromFolders(FilesAndFolders)

FolderIndices = [];
for i = 1:length(FilesAndFolders)
    if (FilesAndFolders(i).isdir == 1 && strcmp(FilesAndFolders(i).name,'.') == 0 && ...
            strcmp(FilesAndFolders(i).name,'..') == 0)
        FolderIndices = [FolderIndices; i];
    end
end
Folders = FilesAndFolders(FolderIndices);

end