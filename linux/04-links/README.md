# LIN-04 - Hard Links and Symbolic Links

## Objective

Understand the difference between hard links and symbolic links by building a practical lab.

Topics covered:

- inode
- hard links
- symbolic links
- link count
- broken symlinks
- links to directories

The goal is to understand how Linux stores files and how different types of links behave.

---

# What is an inode?

Every file in Linux is represented by an **inode**.

An inode stores metadata about a file:

- owner
- group
- permissions
- timestamps
- file size
- location of data blocks

The filename is **not** stored inside the inode.

Instead:

```text
filename
    │
    ▼
 inode
    │
    ▼
 file data
```

To display inode numbers:

```bash
ls -li
```

Example

```text
18311155 original.txt
```

---

# Hard Links

A hard link is another directory entry pointing to the same inode.

Create a hard link

```bash
ln original.txt hard.txt
```

Verify

```bash
ls -li
```

Example

```text
18311155 original.txt
18311155 hard.txt
```

Notice that both files have the same inode.

They are different filenames pointing to the same file.

---

# Hard Link Behavior

Modify the file

```bash
echo "Second line" >> hard.txt
```

Read the original

```bash
cat original.txt
```

Output

```text
Hello Linux
Second line
```

Both filenames reference the same data.

---

Delete one filename

```bash
rm original.txt
```

Verify

```bash
cat hard.txt
```

The file still exists because another hard link points to the same inode.

The inode is removed only when:

- link count reaches zero
- no process has the file open

---

# Symbolic Links

A symbolic link is a separate file that stores a pathname.

Create

```bash
ln -s hard.txt soft.txt
```

Verify

```bash
ls -li
```

Example

```text
18311155 hard.txt
18311220 soft.txt -> hard.txt
```

Notice that the symbolic link has its own inode.

---

# Broken Symbolic Link

Delete the target

```bash
rm hard.txt
```

Read the symbolic link

```bash
cat soft.txt
```

Output

```text
No such file or directory
```

The symbolic link still exists but points to a path that no longer exists.

---

# Symbolic Links to Directories

Hard links to directories are not allowed for normal users.

Example

```bash
ln . hard_directory
```

Result

```text
Operation not permitted
```

Create a symbolic link

```bash
ln -s . soft_directory
```

Verify

```bash
ls -l
```

Example

```text
soft_directory -> .
```

Enter the directory

```bash
cd soft_directory
pwd
```

The symbolic link works like a shortcut to the directory.

---

# Hard Link vs Symbolic Link

| Feature | Hard Link | Symbolic Link |
|----------|-----------|---------------|
| Points to | inode | pathname |
| Same inode | Yes | No |
| Survives target deletion | Yes | No |
| Can link directories | No (normal users) | Yes |
| Can cross filesystems | No | Yes |

---

# Useful Commands

Display inode numbers

```bash
ls -li
```

Display file information

```bash
stat file
```

Create hard link

```bash
ln source target
```

Create symbolic link

```bash
ln -s source target
```

Show symbolic link target

```bash
readlink soft.txt
```

Find symbolic links

```bash
find . -type l
```

---

# Practical Lab

Create workspace

```bash
mkdir ~/links-lab
cd ~/links-lab
```

Create original file

```bash
echo "Hello Linux" > original.txt
```

Create hard link

```bash
ln original.txt hard.txt
```

Verify inode

```bash
ls -li
```

Modify the file

```bash
echo "Second line" >> hard.txt
```

Delete original

```bash
rm original.txt
```

Verify

```bash
cat hard.txt
```

Create symbolic link

```bash
ln -s hard.txt soft.txt
```

Delete target

```bash
rm hard.txt
```

Verify broken link

```bash
cat soft.txt
```

Create symbolic link to directory

```bash
ln -s . soft_directory
cd soft_directory
pwd
```

---

# Interview Questions

### What is an inode?

An inode stores a file's metadata and points to its data blocks. Filenames are directory entries that reference an inode.

---

### What is a hard link?

A hard link is another directory entry pointing to the same inode.

---

### What is a symbolic link?

A symbolic link is a separate file that stores the pathname to another file.

---

### Why does a hard link survive deleting the original file?

Because the inode still has at least one directory entry pointing to it.

---

### Why does a symbolic link break?

Because it stores only the pathname to the target. If the target path disappears, the symbolic link becomes invalid.

---

### Can a hard link point to another filesystem?

No.

---

### Can a symbolic link point to another filesystem?

Yes.

---

# Key Takeaways

- Every file is represented by an inode.
- Filenames are directory entries pointing to an inode.
- Hard links share the same inode.
- Symbolic links have their own inode and store only a pathname.
- Deleting one hard link does not remove the file while another hard link exists.
- Deleting the target of a symbolic link creates a broken link.
- Symbolic links can point to directories and other filesystems.