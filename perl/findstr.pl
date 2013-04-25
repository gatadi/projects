use Getopt::Long;
use File::Find ;

my @searchresults = () ;
my @listOfFiles = ();
my $isTestMode = 0 ;



my $swift = "//depot/swift" ;
my $PROJECTS_ROOT = "$swift/snapfish/projects/2011" ;
my $swiftRoot = $ENV{'SWIFT_ROOT'} ;
my $TEMP = $ENV{"TEMP"};
#for linux os
if ( $^O eq "MSWin32" || $^O eq "cygwin" ) {
    #skip environment variable will be defined
}else{
    $TEMP = "/tmp" ;
}

my $type = "components" ;

my ($action, $match, $replace, $target, $source, $projectFolders, $fpath, $isTestMode, $rel) ;


GetOptions("a|action=s" => \$action,
           "o|oldcomponent=s" => \$match,
           "n|newcomponent=s" => \$replace,
           "t|target=s" => \$target,
           "s|source=s" => \$source,
           "p|projects=s" => \$projectFolders,
           "f|fpath=s" => \$fpath,
           "r|rel=s" => \$rel,
           "d|testMode=s" => \$isTestMode) ;


#print "\naction=$action" ;
#print "\nmatch=$match" ;
#print "\nreplace=$replace" ;
#print "\ntarget=$target" ;
#print "\nsource=$source" ;
#print "\nprojectFolders=$projectFolders";
#print "\nisTestMode=$isTestMode\n\n";


#some components are referring other components directly using dot notation - which is VERY BAD,
#so handling those use cases
my $matchUgly = $match ;
if( $matchUgly =~ /(.*\/)(.*)/  )
{
    $matchUgly = "$matchUgly/$2" ;
}
$matchUgly =~ s/\//\./g ;

my $replaceUgly = $replace ;
if( $replaceUgly =~ /(.*\/)(.*)/  )
{
    $replaceUgly = "$replaceUgly/$2" ;
}
$replaceUgly =~ s/\//\./g ;


#the options for action are
#c1 - find component references in $source, and integrate component & referenced files to $target
#p1 - find page references in $source, and integrate page & referenced files to $target
#c2 - rename/move component in $target
#p2 - rename/move page in $target

#integ - integrates project files from main to project folder
#fc  - finds matching files from list of project folders





main();



sub main
{

    my $usageString = "\nUsage:  perl findstr.pl --a=[c1|c2|p1|p2|integ|fc] [--o=old-component] [--n=new-component] [--t=target] [--s=source] [--d=1|0] [--p=projectfolders]".
            "\n\nc1  -  finds <old-component> references in <source> folder then integrates <old-component> & referenced files to <target>".
            "\n\nc2  -  renamess <old-component> to <new-component>: integrates <old-component> to <new-component>, deletes <old-component>, and updates referenced files".
            "\n\np1  -  finds page references in source folder then integrates page & referenced files to target".
            "\n\np2  -  renames page to new-page: integrates old page to new-page, deletes old page, and updates referenced files".
            "\n\ninteg -  integrates project files from <source> to <target> folder".
            "\n\noptional parameter to run in test mode: 1 - test mode,  0 - default: executes tasks".
            "\n\nfc  -  finds matching files from list of project folders\n\n" ;


    if( $source ne "" )
    {
        if($source eq "main"){
            $source = "snapfish/$source" ;
        }else{
            $source = "snapfish/projects/2011/$source" ;
        }
    }

    if( $target ne "")
    {

        if($target eq "main"){
            $target = "snapfish/$target" ;
        }else{
            $target = "snapfish/projects/2011/$target" ;
        }
    }


    if( ($action ne "fc") && ($action ne "fcr") && ($action ne "integ") 
        && ($action ne "mergedown") && ($action ne "copyup")&& ($action ne "integfiles")
        && ($action ne "c1")  &&  ($action ne "c2") 
        && ($action ne "p1")  &&  ($action ne "p2"))
    {
        die $usageString ;
    }

    if( ($action eq "p1") || ($action eq "p2")  )
    {
        $type = "pages" ;
    }

    if($action eq "integ")
    {
        if( !$source || !$target )
        {
            die "\n\nUsage: integrateProject --s=source-folder --t=target-folder".
            "\nExample: integrateProject --s=main --t=DAM-SOFI\n\n" ;
        }
        integrateProject() ;
    }
    
    if($action eq "mergedown")
    {
        if( !$target )
        {
            die "\n\nUsage: mergedown --t=target-folder".
            "\nExample: mergedown --t=DAM-SOFI\n\n" ;
        }
        if (!$source){
            $source = "snapfish/main";
        }
        mergeProjectDown() ;
    }
    
    if($action eq "copyup")
    {
        if( !$source )
        {
            die "\n\nUsage: copyup --s=source-folder".
            "\nExample: copyup --s=DAM-SOFI\n\n" ;
        }
        if (!$target){
            $target = "snapfish/main";
        }
        copyProjectToMain() ;
    }
    
    if($action eq "integfiles")
    {
        if( !$target )
        {
            die "\n\nUsage: integrateFiles [--s=main] --t=PROJECT-FOLDER --f=components/test/HelloWorld/...".
            "\nExample: integrateFiles [--s=main] --t=DAM-SOFI --f=components/test/HelloWorld/HelloWordView.js\n\n" ;
        }
        if (!$source){
            $source = "snapfish/main";
        }
        integrateFilesFromMainToProject();
    }

    if($action eq "fc")
    {
        if( ! $projectFolders )
        {
            die "\n\nUsage: findConflicts [comma-separated-project-folder-name]".
                "\nExample: findConflicts DAM-SOFI,INF-REORGCMPS,DISC-OPENPLATFORM\n\n";
        }
        listProjectConflictFiles($projectFolders);
    }
    
    if($action eq "fcr")
    {
        if( !$rel )
        {
            die "\n\nUsage: findConflictsFromRel relyear/relnum".
                "\nExample: findConflictsFromRel 2011/20\n\n";
        }
        listProjectConflictFilesFromRel($rel);
    }

    if( ($action eq "c1") || ($action eq "p1") ){
        integrateOldComponentAndReferences() ;
    }
    if( ($action eq "c2") || ($action eq "p2") )
    {
        integrateOldToNew();
        updatePrefix() ;
        markOldComponentsForDelete();
        updateReferences();
    }

    print "\n\n" ;
}


#integrate component and referred files from main to target branch
sub integrateOldComponentAndReferences()
{
    my $searchFolder = "$swiftRoot/$source" ;
    my @results = findComponent($searchFolder) ;

    print "\n\n\n\n==============================================================\n";
    print "\nLIST OF FILES THAT MATCH COMPONENT - $match\n\n";
    foreach(@results)
    {
        print "\n".$_;
    }
    my $count = @results ;
    print "\n\nTotal Files : [$count]" ;
    print "\n\n==============================================================";

    find(\&listFiles, "$searchFolder/$type/$match");
    push(@results, @listOfFiles);
    #reset global array
    @listOfFiles = ();

    print "\nIntegrating old component and its all references files to target branch/folder" ;
    print "\n$swift/$source -> $swift/$target ...\n\n" ;

    foreach(@results)
    {
        my $file = $_;
        $file =~ s/\\/\//g ;
        my $key = "$searchFolder"."/" ;
        $key =~ s/\\/\//g;
        $file =~ s/$key//g ;
        $p4intcmd = "p4 integrate -t $swift/$source/$file $swift/$target/$file" ;
        print "\n$p4intcmd" ;
        if(! $isTestMode){
            system($p4intcmd);
        }
    }
}

#rename component by integrating old component to new component
#open new component files for edit to update component prefix in each file
sub integrateOldToNew
{
    my ($oldComponentFolder, $oldPrefix, $oldComponentName,
        $newComponentFolder, $newPrefix, $newComponentName) = getComponentPrefixAnaName() ;
    my $searchFolder = "$swiftRoot/$target" ;
    print "\n\nSearchFolder=$searchFolder/$type/$match\n" ;
    find(\&listFiles, "$searchFolder/$type/$match");
    my @listOfOldComponentFiles = @listOfFiles ;
    #reset global array
    @listOfFiles = ();

    print "\n\n\n\n==============================================================\n";
    print "\nIntegrating old component to new place with new name" ;
    print "\n$match -> $replace\n\n" ;

    foreach(@listOfOldComponentFiles)
    {
        my $file = $_ ;
        $file =~ s/\\/\//g ;
        my $key = "$searchFolder"."/" ;
        $key =~ s/\\/\//g;
        $file =~ s/$key//g ;

        my $newfile = $file ;
        $newfile =~ s/$oldComponentFolder/$newComponentFolder/g ;
        $newfile =~ s/$oldComponentName/$newComponentName/g ;
        my $p4intcmd = "p4 integrate -t $swift/$target/$file $swift/$target/$newfile" ;
        print "\n$p4intcmd" ;
        if(! $isTestMode){
            system($p4intcmd);
        }
    }
}


#open new component files for edit and update component prefix in each file
sub updatePrefix
{
    my ($oldComponentFolder, $oldPrefix, $oldComponentName,
        $newComponentFolder, $newPrefix, $newComponentName) = getComponentPrefixAnaName() ;

    my $componentFolder = "$swiftRoot/$target/$type/$replace" ;
    find(\&listFiles, $componentFolder);

    my @listOfNewComponentFiles = @listOfFiles ;
    #reset global array
    @listOfFiles = ();

    print "\n\n\n\n==============================================================\n";
    print "\nUpdating new component files with new component prefix\n\n" ;

    foreach(@listOfNewComponentFiles)
    {
        my $file = $_;
        open my $INFILE, '<', $file or die "Open failed: $!" ;
        my @lines = <$INFILE> ;
        my @newLines = () ;
        foreach(@lines)
        {
            my $line = $_ ;
            if( /$oldPrefix/ )
            {
                $line =~ s/$oldPrefix/$newPrefix/g ;
            }
            push(@newLines, $line);
        }
        close $INFILE ;

        my $p4edit = "p4 edit $file" ;
        print "\n$p4edit" ;
        if(! $isTestMode)
        {
            system($p4edit);
            open my $OUTFILE, '>', $file or die "Open failed: $!" ;
            foreach(@newLines)
            {
                print $OUTFILE $_ ;
            }
        }
    }
}


#mark old component files for delete
sub markOldComponentsForDelete
{
    print "\n\n\n\n==============================================================\n";
    print "\n\nMarking old component files for delete\n" ;

    my $componentFolder = "$swiftRoot/$target/$type/$match" ;
    find(\&listFiles, $componentFolder);
    my @listOfOldComponentFiles = @listOfFiles ;
    #reset global array
    @listOfFiles = ();

    foreach(@listOfOldComponentFiles)
    {
        my $file = $_ ;
        my $p4delete = "p4 delete $file" ;
        print "\n$p4delete" ;
        if(! $isTestMode){
            system($p4delete);
        }
    }
}


#open all refrence files for edit and update references
sub updateReferences
{
    print "\n\n\n\n==============================================================\n";
    print "\n\nUpdating all reference files with new component name\n" ;

    my ($oldComponentFolder, $oldPrefix, $oldComponentName,
        $newComponentFolder, $newPrefix, $newComponentName) = getComponentPrefixAnaName() ;


    my $folderToSearch = "$swiftRoot/$target" ;
    my @results = findComponent($folderToSearch) ;
    print "\n\n\n";
    foreach(@results)
    {
        my $file = $_ ;
        my @newLines = () ;

        print "\n------------------------------------------------------------------------\n";
        print "Updating file:\n$file" ;
        print "\n------------------------------------------------------------------------\n\n";

        #open file to write
        my $p4edit = "p4 edit $file" ;
        print "\n$p4edit" ;
        if(! $isTestMode){
            system($p4edit);
        }


        #read flie and search for old component usage and replace with new component
        open my $INFILE, '<', $file or die "Open failed: $!" ;
        my @lines = <$INFILE> ;
        foreach(@lines)
        {
            my $line = $_ ;
            if( /['"]($match)['"]/ )
            {
                print "\nOLD-> ".trim($line) ;
                $line =~ s/$match/$replace/g ;
                print "\nNEW-> ".trim($line)."\n" ;
            }

            if(/$oldPrefix/)
            {
                print "\nOLD-> ".trim($line) ;
                $line =~ s/$matchUgly\.$oldComponentName/$replaceUgly\.$newComponentName/g ;
                print "\nNEW-> ".trim($line)."\n" ;
            }

            push(@newLines, $line);
        }
        close $INFILE ;

        #update file with new component
        if(! $isTestMode)
        {
            open my $OUTFILE, '>', $file or die "Open failed: $!" ;
            foreach(@newLines)
            {
                print $OUTFILE $_ ;
            }
            close $OUTFILE;
        }

    }
}






sub listProjectConflictFiles
{
    my ($projectFolders) = @_ ;
    my @projects = split(/,/, $projectFolders);

    my ($sec, $hour, $day) = localtime ;
    my $timestamp = "$day-$hour-$sec" ;
    my %projectMap = {};
    
    foreach(@projects)
    {
        my $project = $_ ;
        if( $project ne "" )
        {
            print "\nBuilding project $_ file list..." ;
            my $p4cmd = "p4 fstat -P -C -Ol -T \"depotFile\" -F \"^headAction=delete\" $PROJECTS_ROOT/$project/...";
            open(F, "$p4cmd |") or die "Error: Can not execute command> $!\n";
            my @list = <F> ;    
            close F;
            $projectMap{$project} = \@list ;            
        }            
    }


    my %map = {} ;
    my @conflictedFiles = ();
    my %tmap = {};

    foreach(@projects)
    {        
        my $project = $_ ;
        if( $project ne "" )
        {
            my @projectFiles = @{$projectMap{$project}} ;
            foreach(@projectFiles)
            {
                my $originalFilePath = $_ ;
                $originalFilePath =~ s/\n//g;
                $originalFilePath =~ s/\.\.\. depotFile //g;
                my $filePath = $originalFilePath ;
                $filePath =~ s/$project//g;

                if( $map{$filePath} )
                {
                    $tmap{$map{$filePath}} = $map{$filePath};
                    $tmap{$originalFilePath} = $originalFilePath;

                }else
                {
                    $map{$filePath} = $originalFilePath ;
                }

            }
        }
    }

    print "\n\n=========================================================\n\n";
    print "           Conflict Files       \n";
    print "=========================================================\n\n";
    foreach my $key (sort keys (%tmap))
    {
        print "\n$tmap{$key}" ;
    }

}



sub listProjectConflictFilesFromRel()
{
    my ($rel) = @_ ; # for example - 2011/20
    
    my $p4print = "p4 print -o $TEMP/swift.properties //depot/Snapfish/$rel/install/swift.properties" ;    
    if(! $isTestMode){
       system($p4print);        
    }
    
    open my $INFILE, '<', "$TEMP/swift.properties" or die "\nOpen failed: $!";
    my @lines = <$INFILE> ;
    close $INFILE;
    
    my $listOfProjects = "" ;
    foreach(@lines)
    {
        my $projectName = $_ ;
        if(/($PROJECTS_ROOT\/)(.*)/)
        {            
            $projectName = $2 ;
            $projectName =~ s/,\\//g ;                
            $listOfProjects = $listOfProjects.",".$projectName ;
        }
    }
    
    listProjectConflictFiles($listOfProjects) ;
}






#Inegrates all (target) project files from main to target project folder;
sub mergeProjectDown
{
    my $targetProjectFolder = "$swift/$target" ;        
    my $p4cmdTargetProject = "p4 fstat -P -C -Ol -T \"depotFile\" -F \"^headAction=delete\" $targetProjectFolder/...";
    
    print "\n\nExecuting command to list the files in a project folder: $p4cmdTargetProject\n" ;
    open(F, "$p4cmdTargetProject |") or die "Error: Can not execute command: $!";
    my @listOfFiles = <F> ;
    close F;
    
    my @results = ();
    foreach(@listOfFiles)
    {
        my $file = $_ ;
        $file =~ s/\.\.\. depotFile //g ;
        $file = trim($file);  
        chomp($file);
        if( $file eq "" ) {next;}
        
        push(@results, $file);
        #print "\n".$file;          
    }
    my $count = @results ;
    print "\n\nTotal Files in $swift/$target: [$count]\n" ;
    print "\n\nExecuting p4 integ command for each file in a project folder ...\n\n\n" ;
    
    foreach(@results)
    {
        my $targetFile = $_ ;
        my $file = $_ ;
        $file =~ s/$target/$source/g;
        my $p4cmd = "p4 integ -t -i $file $targetFile\n" ;        
        if(!$isTestMode){
            open(F, "$p4cmd |") or die "Error: Can not execute command $!\n";
        }
        
    }
}



#This api will integrate all the files from project folder to main except deleted files
#we don't want deletes to propagate to main, so this api will revert all the delete actions
sub copyProjectToMain
{
    my $projectFolder = "$swift/$source" ; 
    my $p4cmdinteg = "p4 integrate -t -i $projectFolder/... $swift/$target/...\n" ;
    
    print "\nExecuting p4 integ command - You may see few erros with respective to deleted files, don't worry about those as we don't want to integrate deleted files\n\n$p4cmdinteg\n\n\n" ;
       
    if(! $isTestMode){
        system($p4cmdinteg);
    }
    
    print "\n======================================================================\n";
    
    my $p4cmdreverdeletes = "p4 fstat -P -C -Ol -T \"depotFile\" -F \"(headAction=branch | headAction=integrate) & action=delete\"  $swift/$target/...\n" ;    
    print "\n\n\nExecuting p4 revert command to revert all delete actions as we don't want deletes to propagate to main...\n\n\n";
        
    open(F, "$p4cmdreverdeletes |") or die "Error: Can not execute command: $!";
    my @listOfDeletes = <F> ;
    close F;
    foreach(@listOfDeletes)
    {
        my $file = $_ ;
        $file =~ s/\.\.\. depotFile //g ;
        $file = trim($file);  
        chomp($file);
        if( $file eq "" ) {next;}
        system("p4 revert $file");
    }

}


#Inegrates all (target) project files from source to target project folder;
sub integrateProject()
{
    my $targetProjectFolder = "$swift/$target" ;        
    my $p4cmdTargetProject = "p4 fstat -P -C -Ol -T \"depotFile\" -F \"^headAction=delete\" $targetProjectFolder/...";
    
    open(F, "$p4cmdTargetProject |") or die "Error: Can not execute command: $!";
    my @listOfFiles = <F> ;
    close F;
    my %map ={};
    my @listOfTargetFiles = ();
    foreach(@listOfFiles)
    {
        my $file = $_ ;
        $file =~ s/\.\.\. depotFile //g ;
        $file = trim($file);  
        chomp($file);
        if( $file eq "" ) {next;}
        
        #print "\n".$file; 
        push(@listOfTargetFiles, $file);
        my $temp = $file ;
        $temp =~ s/$targetProjectFolder//g ;
        $map{$temp} = $file;
    }
    my $count = @listOfTargetFiles ;
    print "\n\nTotal Files in $swift/$target: [$count]" ;
         
    my $sourceProjectFolder = "$swift/$source" ;   
    my $p4cmdSourceProject = "p4 fstat -P -C -Ol -T \"depotFile\" -F \"^headAction=delete\" $sourceProjectFolder/...";
    
    open(F, "$p4cmdSourceProject |") or die "Error: Can not execute command: $!";
    my @listOfFiles = <F> ;
    close F;
    
    my @listOfFilesToIntegrate = ();
    my @listOfSourceFiles ;
    foreach(@listOfFiles)
    {
        my $file = $_ ;
        $file =~ s/\.\.\. depotFile //g ;
        $file = trim($file);  
        chomp($file);
        if( $file eq "" ) {next;}
        
        my $temp = $file ;
        $temp =~ s/$sourceProjectFolder//g ;
        
        if($map{$temp}){            
            push(@listOfFilesToIntegrate, $file);
        }
        push(@listOfSourceFiles, $file);
    }
    
    $count = @listOfSourceFiles ;
    print "\n\nTotal Files in $swift/$source: [$count]" ;
    
    $count = @listOfFilesToIntegrate ;
    print "\n\nList of files to integrate (which exists in both the project folders) :[$count]\n\n";
    
    foreach(@listOfFilesToIntegrate)
    {
        my $file = $_ ;
        $file =~ s/$source/$target/g ;
        
        my $p4integCmd = "p4 integ -t -i $_ $file\n" ;
        print $p4integCmd ;
        if(! $isTestMode){
            system($p4integCmd);
        }
    }
}


#This API can be used to pull a file or a folder from main to a project folder 
#for project coding
sub integrateFilesFromMainToProject
{
    
    my $p4intcmd = "p4 integrate -t -i $swift/$source/$fpath $swift/$target/$fpath\n" ;
    print "\n$p4intcmd" ;
    if(! $isTestMode){
        system($p4intcmd);
        system("p4 submit");
    }
}





#integrates files listting from local dev box, this creats problem if you don't have
#latest code, so p4 sync should be invoked before this api is used
sub copyProjectToMainVer1
{
    my $projectFolder = "$swiftRoot/$source" ;
    find(\&listFiles, $projectFolder);
    my @results = () ;
    push(@results, @listOfFiles);
    #reset global array
    @listOfFiles = ();

    print "\n\n\n\n==============================================================\n";
    print "\nLIST OF FILES TO INTEGRATE\n\n";
    foreach(@results)
    {
        print "\n".$_;
    }
    my $count = @results ;
    print "\n\nTotal Files : [$count]" ;
    print "\n\n==============================================================";

    foreach(@results)
    {
        my $file = $_;
        $file =~ s/\\/\//g ;
        my $key = "$projectFolder"."/" ;
        $key =~ s/\\/\//g;
        $file =~ s/$key//g ;
        $p4intcmd = "p4 integrate -t -i $swift/$source/$file $swift/$target/$file\n" ;
        print "\n$p4intcmd" ;
        if(! $isTestMode){
            system($p4intcmd);
        }
    }

}

#Integrates files listing from perforce, so it is safe to use this api
sub copyProjectToMainVer2
{
    my $projectFolder = "$swift/$source" ;    
    print "\n$projectFolder\n";
    my $p4cmd = "p4 fstat -P -C -Ol -T \"depotFile\" -F \"^headAction=delete\" $projectFolder/...";
        
    
    open(F, "$p4cmd |") or die "Error: Can not execute command: $!";
    my @listOfFiles = <F> ;
    my @results = ();
    
    print "\n\n\n\n==============================================================\n";
    print "\nLIST OF FILES TO INTEGRATE\n\n";
    
    foreach(@listOfFiles)
    {
        my $file = $_ ;
        $file =~ s/\.\.\. depotFile //g ;
        $file = trim($file);  
        chomp($file);
        if( $file eq "" ) {next;}
        
        print "\n".$file;  
        push(@results, $file);
    }
    my $count = @listOfFiles ;
    print "\n\nTotal Files : [$count]" ;
    print "\n\n==============================================================";
    
    foreach(@results)
    {
        my $file = $_;                
        $file =~ s/$projectFolder/$swift\/$target/g ;
        $p4intcmd = "p4 integrate -t -i $_ $file\n" ;
        print "\n$p4intcmd" ;
        if(! $isTestMode){
            system($p4intcmd);
        }
    }
}









sub getComponentPrefixAnaName
{
    my $oldComponentFolder = $match ;
    my $oldComponentName ;
    if( $oldComponentFolder =~ /(.*\/)(.*)/  )
    {
        $oldComponentFolder = $1 ;
        $oldComponentName = $2 ;

    }else
    {
        die "\nBug in regular expression... look at scripts/windows/findstr.pl->getComponentPrefixAnaName()" ;
    }

    my $newComponentFolder = $replace ;
    my $newComponentName ;
    if( $newComponentFolder =~ /(.*\/)(.*)/  )
    {
        $newComponentFolder = $1 ;
        $newComponentName = $2 ;
    }else
    {
        die "\nBug in regular expression... look at scripts/windows/findstr.pl->getComponentPrefixAnaName()" ;
    }

    my $oldPrefix = $match ;
    $oldPrefix =~ s/\//\./g ;
    $oldPrefix = "$oldPrefix.$oldComponentName" ;
    my $newPrefix = $replace ;
    $newPrefix =~ s/\//\./g ;
    $newPrefix = "$newPrefix.$newComponentName" ;

    return ($oldComponentFolder, $oldPrefix, $oldComponentName,
            $newComponentFolder, $newPrefix, $newComponentName) ;
}






sub _findComponent
{
    eval
    {
        if(-f && (/.js/ || /.html/ || /.properties/) )
        {
            my  $found = 0 ;
            open my $INFILE, '<', $_ or die "Open failed: $!";
            my @lines = <$INFILE> ;
            close $INFILE;
            my @linesMatched = () ;
            foreach(@lines)
            {
                my $line = $_ ;
                if( $line =~ /['"]($match)['"]/)
                {
                    push(@linesMatched, trim($line)) ;
                    $found = 1 ;
                }

                if( $line =~ /$matchUgly/ )
                {
                    push(@linesMatched, trim($line)) ;
                    $found = 1 ;
                }
            }

            if( $found == 1)
            {
                print "\n\n---Found component usage: $File::Find::name -----\n" ;
                foreach(@linesMatched){
                    print "\n$_" ;
                }
                push(@searchresults, "$File::Find::name");
            }
        }
    }
}

sub findComponent
{
    my ($folder) = @_[0] ;
    find(\&_findComponent, $folder);

    return @searchresults ;
}


sub _findString
{
    eval
    {
        if(-f && (/.js/ || /.html/ || /.properties/ || /.css/) )
        {

            my  $found = 0 ;
            open my $INFILE, '<', $_ or die "Open failed: $!";
            my @lines = <$INFILE> ;
            close $INFILE;
            my @linesMatched = () ;
            foreach(@lines)
            {
                my $line = $_ ;
                if( $line =~ /$match/)
                {
                    push(@linesMatched, trim($line));
                    $found = 1 ;
                }
            }

            if( $found == 1)
            {
                print "\n\n-------------------------------------------------------------" ;
                print "\n$File::Find::name\n\n" ;
                foreach(@linesMatched){
                    print "\n$_" ;
                }
                push(@searchresults, $File::Find::name);
            }
        }
    }
}


sub findString
{
    my ($folder) = @_[1] ;
    find(\&_findString, $folder);

    return @searchresults ;
}

sub replaceString
{
    my (@results) = @_ ;

    foreach(@results)
    {
        my $file = $_ ;

        print "\n------------------------------------------------------------------------\n";
        print "Updating file:\n$file" ;
        print "\n------------------------------------------------------------------------\n\n";

        open my $FILE, '<', $file or die "Can not open file : $!" ;
        my @content = <$FILE> ;
        close $FILE;

        my @newcontent = () ;
        foreach(@content)
        {
            my $line = $_ ;
            if( $line =~ /$match/)
            {
                print "\nOLD-> ".trim($line) ;
                $line =~ s/$match/$replace/ ;
                print "\nNEW-> ".trim($line)."\n" ;
            }
            push(@newcontent, $line);
        }

        open my $OUTFILE, '>', $file or die "Can not open file: $!" ;
        print $OUTFILE @newcontent ;
        close $OUTFILE;
    }
}


sub listFiles
{
    eval
    {
        if(-f)
        {
            push(@listOfFiles, "$File::Find::name");
        }
    }
}


sub trim
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

